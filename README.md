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

## Conectar Supabase Auth

1. Crea un proyecto en Supabase.
2. En **Project Settings → API**, copia el **Project URL** y la llave **anon/publicable** en `supabase-config.js`.
3. En **SQL Editor**, ejecuta el contenido de `supabase-schema.sql`. La tabla `profiles` tiene RLS; cada registro nuevo obtiene rol `customer`. Los usuarios no pueden asignarse el rol `walker` ni `admin` desde el navegador.
4. Crea cuentas con los correos de Max y Martín desde el formulario de clientes y confirma los correos si Supabase lo solicita.
5. Desde el SQL Editor de Supabase, asigna los roles especiales a sus correos registrados:

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

6. Publica los cambios para que Vercel los despliegue. Los correos de clientes deben confirmar la dirección según la configuración de autenticación de Supabase.

La llave `anon`/publicable está diseñada para exponerse en el navegador; la seguridad depende de las políticas RLS incluidas en el esquema. **Nunca** pongas en `supabase-config.js` una llave `service_role`/secreta. La URL y la llave publicable aún no están configuradas, así que registro e inicio de sesión permanecerán deshabilitados hasta conectar un proyecto.

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
