# ASI-2026-Repo
## ENVIO YA

Proyecto enfocado en la arquitectura de un sistema de domicilios.

---

## 👥 Integrantes

* **Alejandro Ceballos**
* **Edward Fernandez**

---

## Contexto del Proyecto y Reto Arquitectónico

### El Problema
**Una plataforma de domicilios** gestiona el ciclo de vida completo de un pedido: asigna repartidores, permite el seguimiento visual de la ubicación en el mapa mientras la orden va en camino y actualiza estados de entrega.

### El Reto Técnico
**Con miles de repartidores activos**, el sistema recibe **miles de actualizaciones de posición GPS por minuto**.

Esto nos obliga a separar arquitectónicamente los **datos efímeros** (ubicación actual) de los **datos durables** (pedidos, clientes, cobros).