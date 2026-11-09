# Pasea — app de paseos para mascotas

Aplicación web responsive en español para buscar paseadores, registrar perritos y solicitar paseos. La autenticación utiliza Supabase Auth; la página es estática y no requiere un proceso de compilación.

## Funciones

- Listado con un solo paseador: Maximiliano Morales Alcántara.
- Perfil editable de Max con zona, descripción, foto, precio, días y horarios, tamaños de perro y preferencias; se sincroniza con Supabase.
- Registro e inicio de sesión de clientes mediante Supabase Auth.
- Acceso por enlace de correo sin contraseña y flujo de creación/recuperación de contraseña.
- Registro en la nube de perros y fotos privadas para cada cuenta.
- Solicitudes de paseo con fecha, horario publicado, perro, domicilio, teléfono y precio; Max puede confirmar o rechazar.
- Vistas separadas de solicitudes para el cliente y el paseador, con controles de acceso en Supabase.

No se muestran reseñas, calificaciones ni verificaciones inventadas. Los datos de contacto y domicilio de una solicitud solo son visibles para el cliente y el paseador asignado. No se procesan pagos en la app.

## Supabase: base de datos y almacenamiento

Supabase Auth ya está conectado en `supabase-config.js` y `supabase-schema.sql` ya se ejecutó en el proyecto. Para habilitar perfiles compartidos, fotos y solicitudes:

1. Abre el SQL Editor del proyecto Supabase.
2. Copia y ejecuta el contenido de `supabase-marketplace.sql`. Esto crea las tablas de perfiles, perros y solicitudes, las políticas RLS y los buckets privados de fotos. Al volver a ejecutarlo también elimina la lectura anónima anterior de perfiles y fotos de paseadores.
3. Max y Martín deben aceptar las invitaciones que recibieron y crear sus contraseñas. Los roles actuales son `walker` para Max y `admin` para Martín.

Las fotos se redimensionan antes de subirlas y cada archivo se limita a 2 MB en el bucket. El perfil de paseador solo se muestra como disponible cuando Max publica precio, al menos un día y un horario. Al solicitar un paseo, el cliente elige una fecha/horario, registra el domicilio y teléfono de recogida, y recibe una solicitud pendiente; Max la confirma o rechaza desde **Perfiles → Solicitudes de paseo**. El precio se informa, pero no se cobra desde la app.

La app usa el plan gratuito de Supabase, sujeto a sus cuotas y condiciones vigentes; no integra servicios de pago externos. Las cuotas gratuitas tienen límites y pueden cambiar. Si se exceden, Supabase puede requerir una pausa o un cambio de plan para seguir utilizando el proyecto.

Max puede entrar con **Enviarme enlace de acceso**, o usar **Crear o recuperar contraseña** para recibir un enlace seguro y definir su contraseña. La disponibilidad del correo depende de los límites configurados en Supabase Auth.

La app exige una sesión y un perfil con rol válido antes de mostrar su contenido. RLS restringe la lectura y modificación de datos; las fotos de paseadores ahora se sirven con URL firmada después del inicio de sesión. Ejecuta `supabase-marketplace.sql` en Supabase para aplicar los permisos que bloquean accesos anónimos existentes. La llave `anon`/publicable está diseñada para exponerse en el navegador; **nunca** pongas en `supabase-config.js` una llave `service_role`/secreta.

La primera vez que Max o Martín inicie sesión en este navegador, la app intenta importar el perfil anterior guardado localmente, si lo había. Los datos viejos de perros también se importan al iniciar sesión en la cuenta de cliente correspondiente. La importación no borra el respaldo local.

## Pagos y comisión

Los cobros están deshabilitados y no se muestran comisiones. Antes de habilitar pagos reales se deberán decidir el país y moneda de operación, tarifas, impuestos, cancelaciones y reembolsos, además de elegir un proveedor que permita pagar a terceros.

## Siguientes mejoras

1. Agregar fechas no recurrentes, duración del paseo y reglas para cancelaciones/reagendados.
2. Implementar revisión administrativa antes de publicar perfiles y reseñas ligadas a paseos completados.
3. Definir políticas de privacidad, consentimiento para domicilios y fotos, y términos locales.
4. Integrar pagos solo después de elegir un proveedor y revisar sus tarifas, cuotas y requisitos legales.

No agregues llaves privadas ni credenciales al repositorio. Usa variables de entorno y configura sus valores únicamente en el servicio de despliegue.
