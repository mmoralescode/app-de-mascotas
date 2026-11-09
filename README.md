# Pasea — app de paseos para mascotas

Prototipo web responsive en español para buscar paseadores, registrar perritos y solicitar paseos. El proyecto es una página estática sin dependencias de compilación: abre `index.html` en un navegador o publícala con cualquier hosting estático.

## Funciones demostrativas

- Listado con un solo paseador: Maximiliano Morales Alcántara.
- Perfil editable de Max con zona, descripción, foto, precio, disponibilidad, horarios, tamaños de perro y preferencias.
- Formulario local para guardar un perfil privado de desarrollador que no se muestra en el listado.
- Registro de uno o más perros con nombre, cantidad, raza, tamaño, comportamiento y foto.
- Solicitudes de paseo cuando el perfil de Max tenga precio, horarios y disponibilidad configurados.
- Vista de paseos solicitados.

No se muestran precios, reseñas, calificaciones ni verificaciones inventadas. La información introducida se guarda únicamente en el almacenamiento local del navegador; no hay cuentas, base de datos ni sincronización entre dispositivos. El perfil privado de desarrollador tampoco está autenticado ni cifrado: no guardes datos sensibles ahí.

## Pagos y comisión

Los cobros están deshabilitados y no se muestran precios ni porcentajes de comisión. La tarifa y la distribución de ingresos se decidirán antes de habilitar pagos reales.

Para operar pagos reales se necesita una entidad legal y una cuenta comercial, además de integrar un proveedor de pagos que admita marketplace y pagos a terceros. Cada paseador tendría que completar el alta y verificación de identidad exigida por el proveedor. El checkout debe alojarse en el proveedor de pagos; esta aplicación no debe recopilar datos de tarjetas.

Antes de habilitar cobros hay que decidir el país y moneda de operación, tarifa, quién absorbe comisiones e impuestos, reglas de cancelación/reembolso, tiempos de liberación, manejo de contracargos y requisitos fiscales.

## Para convertirlo en producto

1. Añadir autenticación y roles (familia, paseador y administración).
2. Crear una API y base de datos para usuarios, mascotas, documentos de verificación, disponibilidad, reservas, calificaciones y pagos.
3. Implementar revisión administrativa antes de publicar perfiles y un flujo de reseñas ligado a paseos completados.
4. Integrar pagos divididos con el proveedor elegido, webhooks firmados y conciliación de transferencias.
5. Añadir controles de acceso, protección de datos, consentimiento para ubicación/fotos, políticas de privacidad y términos locales.

No agregues llaves privadas ni credenciales al repositorio. Usa variables de entorno y configura sus valores únicamente en el servicio de despliegue.
