Domicilios con seguimiento en tiempo real

--El problema: 
Una plataforma de domicilios que asigna repartidores y muestra su
ubicación en el mapa mientras el pedido va en camino.

## 1. ¿Dónde viven las posiciones de los repartidores y por qué no en PostgreSQL?
-Las posiciones actuales de los repartidores viven en Redis, un almacén de datos en memoria, debido a que permite realizar lecturas y escrituras con una latencia muy baja. Esto es importante porque la ubicación de los repartidores puede actualizarse constantemente y debe estar disponible en tiempo real para consultar rápidamente su posición actual.
No se utiliza PostgreSQL como almacenamiento principal de estas posiciones porque se trata de información temporal y de alta frecuencia de actualización. Almacenar cada cambio de ubicación de manera permanente en una base de datos relacional generaría un volumen innecesario de operaciones y datos históricos que no son necesarios para conocer la posición actual.

## 2. Si Redis se reinicia y pierde las posiciones, ¿qué se rompe? ¿Es aceptable?
-- El cliente perderia la visualizacion la ubicacion entiempo real del domiciliario.
-- La aplicacion no tiene la visualizacion de los repartidores en el mapa afectando la asignacion de pedidos al repartidor mas cercano.
-- Es aceptable debido a que los datos principales del pedido, el usuario, facturas y demas datos del negocio se almacenan de manera permanente en la base de datos Postgres
## 3. Si el módulo de seguimiento se cae, ¿se puede seguir pidiendo comida?
Si, se puede seguir pidiendo comida debido a que los demas datos del negocio se almacenan en una base de datos relacional, permitiendo que el resto de las funciones del los otros modulos continuen operativas.