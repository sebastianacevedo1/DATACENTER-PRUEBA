Simulación de arquitectura de Data Center contenerizada con Docker, que integra gestión de NAT en nodos, servidor web con Nginx, backend en Python, replicación de bases de datos SQL y pruebas de carga y ancho de banda.
Proyecto de infraestructura y redes que simula el despliegue de un Data Center mediante contenedores con Docker Compose. 
La arquitectura está organizada en tres componentes principales:   
- Nodos y Conectividad (nodo/): Entorno contenerizado encargado de gestionar configuraciones de red, reglas NAT (ver-nat.sh) y contenedores cliente.
- Servicios y Replicación (servicios/): Despliegue de un servidor web con Nginx, una aplicación backend en Python (app.py), respaldo de datos en .sql y una base de datos con arquitectura de replicación primario-réplica.
- Pruebas de Rendimiento (pruebas/): Conjunto de scripts en JavaScript para medir el ancho de banda y ejecutar pruebas de carga sobre el servidor web y la base de datos.
