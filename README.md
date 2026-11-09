# Pasea — app de paseos para mascotas

Prototipo web responsive en español para buscar paseadores, registrar perritos y solicitar paseos. La autenticación real utiliza Supabase Auth; la página sigue siendo estática y no requiere un proceso de compilación.

## Funciones demostrativas

- Listado con un solo paseador: Maximiliano Morales Alcántara.
- Perfil editable de Max con zona, descripción, foto, precio, disponibilidad, horarios, tamaños de perro y preferencias.
- Registro e inicio de sesión de clientes mediante Supabase Auth.
- Acceso de Max como paseador y de Martín Morales como administrador, una vez asignados esos roles de forma administrativa en Supabase.
- Registro de uno o más perros con nombre, cantidad, raza, tamaño, comportamiento y foto.
- Solicitudes de paseo cuando el perfil de Max tenga precio, horarios y disponibilidad configurados.
- Vista de paseos solicitados.

No se muestran precios, reseñas, calificaciones ni verificaciones inventadas. Supabase protege las cuentas y sus contraseñas. Los datos de mascotas, solicitudes y el perfil editable de Max todavía se guardan en el almacenamiento local por usuario/navegador; aún no se sincronizan con la base de datos ni con otros dispositivos.

## Supabase Auth

Supabase Auth ya está conectado en `supabase-config.js`, el esquema de `supabase-schema.sql` ya se ejecutó en el proyecto, y la URL de Vercel está permitida como retorno después de confirmar el correo.

1. Max y Martín deben crear sus cuentas desde **Entrar → Crear cuenta cliente** con los correos que usarán. Confirmen esos correos si Supabase lo solicita.
2. Después de crear las cuentas, desde el SQL Editor de Supabase asigna el rol adecuado por correo:

   ```sql
   update public.profiles p
   set role = 'walker'
   from auth.users u
   where p.id = u.id and lower(u.email) = lower('CORREO_DE_MAX');

   update public.profiles p
   set role = 'admin'
   from auth.users u
   where p.id = u.id and lower(u.email) = lower('CORREO_DE_MARTIN');
   ```

3. Max inicia sesión con su cuenta de paseador; Martín inicia sesión con su cuenta de administrador. Los roles no se pueden cambiar desde el navegador.

La llave `anon`/publicable está diseñada para exponerse en el navegador; la seguridad depende de las políticas RLS incluidas en el esquema. **Nunca** pongas en `supabase-config.js` una llave `service_role`/secreta.

## Pagos y comisión

Los cobros están deshabilitados y no se muestran precios ni porcentajes de comisión. La tarifa y la distribución de ingresos se decidirán antes de habilitar pagos reales.

Para operar pagos reales se necesita una entidad legal y una cuenta comercial, además de integrar un proveedor de pagos que admita marketplace y pagos a terceros. Cada paseador tendría que completar el alta y verificación de identidad exigida por el proveedor. El checkout debe alojarse en el proveedor de pagos; esta aplicación no debe recopilar datos de tarjetas.

Antes de habilitar cobros hay que decidir el país y moneda de operación, tarifa, quién absorbe comisiones e impuestos, reglas de cancelación/reembolso, tiempos de liberación, manejo de contracargos y requisitos fiscales.

## Para convertirlo en producto

1. Mover los datos de mascotas, perfiles, disponibilidad y reservas de `localStorage` a tablas con políticas RLS.
2. Crear almacenamiento seguro para documentos de verificación y fotos de mascotas.
3. Implementar revisión administrativa antes de publicar perfiles y un flujo de reseñas ligado a paseos completados.
4. Integrar pagos divididos con el proveedor elegido, webhooks firmados y conciliación de transferencias.
5. Añadir controles de acceso, protección de datos, consentimiento para ubicación/fotos, políticas de privacidad y términos locales.

No agregues llaves privadas ni credenciales al repositorio. Usa variables de entorno y configura sus valores únicamente en el servicio de despliegue.
