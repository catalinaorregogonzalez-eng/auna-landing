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

## 2026-08-16 — Comentario desactualizado en el código

El comentario del inicio de `index.html` dice que el bloque `PIXEL_META` está al
final del `<head>`; en realidad está al final del `<body>` (línea ~605).
