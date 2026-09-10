# Notas para Maurits

Cosas que no se pueden resolver desde una sesión de trabajo en la página.

## 2026-08-16 — Cloudflare está bloqueando a los buscadores con IA

La zona `catalinaorrego.com` sirve un `robots.txt` administrado por Cloudflare
que bloquea a `ClaudeBot`, `GPTBot`, `CCBot`, `Google-Extended`,
`meta-externalagent`, `Amazonbot`, `Applebot-Extended` y `Bytespider`.

Los datos estructurados y el resto del trabajo de posicionamiento ya están en la
página, pero mientras ese bloqueo siga activo, ChatGPT, Claude y Google AI
Overviews no pueden leerla ni citarla. (Google, Bing, PerplexityBot y
OAI-SearchBot sí pueden.)

Se cambia en el panel de Cloudflare, en la zona `catalinaorrego.com` →
AI Crawl Control / bloqueo de rastreadores de IA. No se puede cambiar desde el
repositorio: el `robots.txt` del sitio se antepone al nuestro.

## 2026-08-16 — El correo del pie de página parece tener un error

Dice `anuaconsultoriaa@gmail.com` — "anua" en vez de "auna", y una "a" de más al
final. Es la única forma de contacto además del calendario. Confirmar con
Catalina antes de cambiarlo.

## 2026-09-10 — Todo el rediseño de marca (AUNAR) está listo, esperando merge

Esta sesión se abrió en la rama `claude/aunar-website-redesign-xko7jt`, no
directo sobre `main`, y ya tiene un PR abierto:
https://github.com/catalinaorregogonzalez-eng/auna-landing/pull/2

Ahí quedó todo el trabajo del cambio de marca de Aúna a AUNAR que Catalina fue
aprobando por partes a lo largo de la sesión: nombre nuevo en todo el sitio,
paleta de colores y tipografía del manual de marca, el logo real (extraído del
ZIP de identidad que ella mandó, ya no la reconstrucción a mano de un
screenshot), tono institucional en vez de primera persona, los planes con
horas y duración detalladas, ajustes de menú, y por último el video que ella
grabó conectado en la sección "Conócenos en video" (con una portada sacada del
propio video).

Catalina ya dio el visto bueno a todo esto — el último "sí, así" fue sobre el
tamaño del cuadro del video. No hice merge del PR yo mismo porque esta sesión
no me dio esa instrucción y fusionar a `main` es lo que dispara el sitio en
vivo; eso quedó para que alguien lo revise en GitHub y lo fusione cuando le
parezca bien. Mientras el PR no se fusione, nada de esto está en
`auna.catalinaorrego.com`.

## 2026-08-16 — Comentario desactualizado en el código

El comentario del inicio de `index.html` dice que el bloque `PIXEL_META` está al
final del `<head>`; en realidad está al final del `<body>` (línea ~605).
