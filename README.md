# Pasea — app de paseos para mascotas

Prototipo web responsive en español para buscar paseadores, registrar perritos y solicitar paseos. El proyecto es una página estática sin dependencias de compilación: abre `index.html` en un navegador o publícala con cualquier hosting estático.

## Funciones demostrativas

- Búsqueda de paseadores por zona y tamaño de perro.
- Perfiles de ejemplo con insignia de verificación, calificación, precio y preferencias como bicicleta, otros perros y uso de correa.
- Registro de uno o más perros con nombre, cantidad, raza, tamaño, comportamiento y foto.
- Solicitudes de paseo con fecha, horarios disponibles de ejemplo, dirección y teléfono de contacto.
- Vista de paseos solicitados y configuración local de disponibilidad, días y horarios del paseador.
- Resumen ilustrativo de comisión y pago al paseador.

Los perfiles, fechas y calificaciones son datos de muestra. La información introducida se guarda únicamente en el almacenamiento local del navegador; no hay cuentas, base de datos ni sincronización entre dispositivos.

## Pagos y comisión

La pantalla muestra una comisión **de ejemplo** del 20% para la plataforma y 80% para el paseador. No se cobra dinero ni se hacen transferencias en este prototipo. Estos porcentajes no están establecidos como precio final.

Para operar pagos reales se necesita una entidad legal y una cuenta comercial, además de integrar un proveedor de pagos que admita marketplace y pagos a terceros —por ejemplo, Stripe Connect o una alternativa disponible en el país donde opere el servicio—. Cada paseador tendría que completar el alta y verificación de identidad exigida por el proveedor. El proveedor recibiría el pago del cliente, descontaría sus propias comisiones e impuestos aplicables, y transferiría al paseador el importe que corresponda; la plataforma recibiría su comisión según el contrato y la configuración del proveedor.

Antes de habilitar cobros hay que decidir el país y moneda de operación, comisión definitiva, quién absorbe comisiones e impuestos, reglas de cancelación/reembolso, tiempos de liberación, manejo de contracargos y requisitos fiscales. No se deben recopilar datos de tarjetas directamente en esta aplicación; el checkout de producción debe alojarse en el proveedor de pagos.

## Para convertirlo en producto

1. Añadir autenticación y roles (familia, paseador y administración).
2. Crear una API y base de datos para usuarios, mascotas, documentos de verificación, disponibilidad, reservas, calificaciones y pagos.
3. Implementar revisión administrativa antes de publicar perfiles y un flujo de reseñas ligado a paseos completados.
4. Integrar pagos divididos con el proveedor elegido, webhooks firmados y conciliación de transferencias.
5. Añadir controles de acceso, protección de datos, consentimiento para ubicación/fotos, políticas de privacidad y términos locales.

No agregues llaves privadas ni credenciales al repositorio. Usa variables de entorno y configura sus valores únicamente en el servicio de despliegue.
