# Domicilios con seguimiento en tiempo real

El problema: 
Una plataforma de domicilios que asigna repartidores y muestra su
ubicación en el mapa mientras el pedido va en camino.

## 1. ¿Dónde viven las posiciones de los repartidores y por qué no en PostgreSQL?
Las posiciones **actuales** de los repartidores viven en **Redis**, un almacén de datos en memoria, por tres razones:

- **Latencia baja.** Redis permite lecturas y escrituras en memoria, y la ubicación se actualiza constantemente y debe estar disponible casi al instante para mostrarla en el mapa.
- **Consultas geoespaciales nativas.** Redis GEO resuelve de forma directa y rápida la pregunta "¿qué repartidores disponibles hay cerca de este punto?", que es la base de la asignación.
- **Datos temporales.** La posición solo importa mientras es reciente. Cada posición lleva un **TTL**: si un repartidor deja de reportar (se desconecta o pierde señal), su posición expira sola y deja de aparecer como disponible.

**Por qué no PostgreSQL como almacenamiento principal de posiciones:** se trata de información temporal y de alta frecuencia de actualización. Guardar cada cambio de ubicación de forma permanente en una base relacional generaría un volumen innecesario de escrituras y de datos históricos que no se necesitan para conocer la posición actual, y competiría por recursos con las operaciones críticas del negocio (pedidos, pagos).

## 2. Si Redis se reinicia y pierde las posiciones, ¿qué se rompe? ¿Es aceptable?
**Qué se rompe (de forma temporal):**

- El cliente pierde la visualización de la ubicación en tiempo real del repartidor.
- La aplicación no tiene las posiciones de los repartidores en el mapa, lo que afecta la asignación del pedido al repartidor más cercano.

**Qué NO se rompe:** los datos principales del pedido, el usuario, las facturas y demás datos del negocio se almacenan de forma permanente en PostgreSQL. Un pedido ya asignado conserva su repartidor aunque Redis se haya reiniciado.

**Recuperación automática:** los repartidores activos reenvían su posición cada pocos segundos, así que Redis se repuebla solo. El tiempo máximo de recuperación es aproximadamente el **5 segundos**

**Comportamiento durante la ventana de recuperación:**

- Al cliente se le muestra "ubicación no disponible" o la última posición conocida, en lugar de un error.
- Las asignaciones nuevas se **encolan y se reintentan** hasta que haya posiciones disponibles, en lugar de fallar.

**¿Es aceptable?** Sí. La pérdida es temporal, se autocorrige en segundos, no afecta datos del negocio y tiene un comportamiento degradado definido.

## 3. Si el módulo de seguimiento se cae, ¿se puede seguir pidiendo comida?
Sí, se puede seguir pidiendo, y la razón principal es el aislamiento: 
El flujo de pedidos no depende de forma síncrona del módulo de seguimiento. Además, los datos del negocio viven en PostgreSQL, así que los demás módulos (pedidos, pagos, comercios, notificaciones) siguen operativos.

Con el seguimiento caído se degrada la experiencia de usuario:

- El cliente no ve el mapa en vivo.
- La asignación depende de las posiciones, por lo que los pedidos nuevos quedan en estado "pendiente de asignación" y se reintentan automáticamente cuando el seguimiento se recupera. Como respaldo opcional, se puede asignar por zona.
- Los cambios de estado del pedido (recogido, entregado) **no dependen del seguimiento** y siguen funcionando.

- Mostrar un mensaje claro al cliente en lugar de un error.

**En resumen:** se puede pedir, pero la experiencia se degrada de forma controlada, sin mapa en vivo y con asignación diferida.



## Supuestos de escala

- Hora pico: 5.000 repartidores activos y 10.000 usuarios concurrentes.
- Reporte de ubicación: cada 5 s por repartidor, es decir, unas 1.000 escrituras/s en Redis.
- Pedidos en pico: unos 3.000 por hora.
- Crecimiento: ×5 en 12 meses.
- Cobertura: una ciudad al inicio, con expansión a más ciudades.