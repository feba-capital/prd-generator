# Step 0 -> Language Selection

Always ask this before any other interaction:

> What language would you like to use for this session?

Options:

1. English (default)
2. Brazilian Portuguese
3. Spanish
4. Chinese (Simplified)
5. Other, specify

Behavior:

- The chosen language applies to the conversation, generated docs, and any handoff message.
- For all listed languages, translate user-facing PRD section headings, intros, and prose into the chosen language. Keep technical terms in English (PRD, TBD, Proposed, Assumed, BIGINT, RLS, endpoint).
- If the user picks "Other, specify", proceed and say: `I will try to respond in {language}. Quality may vary outside the listed languages.` Do not block.
- Keep the language choice lightweight. This step should take one click for the common path.

Localized prompt references (use the same language to ask the question if the user already wrote in that language):

PT-BR:
> Qual idioma você quer usar nesta sessão?
>
> 1. English
> 2. Português do Brasil
> 3. Espanhol
> 4. Chinês (Simplificado)
> 5. Outro, especificar

ES:
> ¿En qué idioma quieres trabajar esta sesión?
>
> 1. English
> 2. Português do Brasil
> 3. Español
> 4. 中文 (Simplified)
> 5. Otro, especificar

ZH:
> 这次会话你想用哪种语言?
>
> 1. English
> 2. Português do Brasil
> 3. Español
> 4. 中文 (简体)
> 5. 其他, 请说明
