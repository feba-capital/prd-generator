# Step 2 -> Optional MVP Check

Entry prompt:

> Want to run a quick MVP check? 7 questions, helps avoid a bloated v1. Skip if you already thought through the scope.

Options:

1. Run the check
2. Skip, I already scoped it

Question format rule:

- Use 2 opinionated options plus 1 free-text fallback for each question.
- Guide, do not block. The user always has the final decision.

## Q1. Who is the primary user?
1. Operational user with a frequent, urgent day-to-day pain.
2. Decision-maker or manager who needs visibility, control, or speed.
3. Free text.

## Q2. What is the ONE thing this user cannot solve today?
1. Execute a critical task simply, quickly, without depending on others.
2. Get clarity to decide or act, because today the info is scattered, confusing, or manual.
3. Free text.

## Q3. If you could only deliver that one thing, would it be useful on its own?
1. Yes, it solves a real pain standalone, even without automation or integrations.
2. Yes, as long as it delivers the core result end-to-end, even in a simple way.
3. No, standalone it does not deliver enough value; it depends on other features or a complementary flow.
4. Free text.

Signal behavior for Q3 option 3:

- Skip `## Future Versions`
- Add `## Launch Dependencies`
- Do not block. Continue to Step 3 normally

## Q4. What is the minimum end-to-end flow?
1. User triggers action -> system processes -> result visible in the same session.
2. User triggers action -> processing takes time -> result arrives later.
3. Free text.

## Q5. What is out of the skateboard but obvious for v2?
1. Technical deferrals: automation, integrations, scale, performance.
2. Product deferrals: advanced features, collaboration, analytics, customization.
3. Free text.

## Q6. What real behavior would prove the MVP worked?
1. Retention: user comes back repeatedly without being pushed.
2. Conversion: user completes the main flow and demonstrates real value.
3. Free text.

## Q7. Is there real data to validate what the skateboard should be?
1. Yes, I have data from existing users, tickets, feedback, or a clear segment.
2. Partially, a strong hypothesis with early signals.
3. No, it is a bet based on intuition.
4. Free text.

Signal behavior for Q7 option 3:

- Add `## Validation Plan` before `## Implementation Readiness`
- Default fields: sample size, time window, success metric, kill threshold
- Tag defaults as `Assumed { question: "...", default: "...", flip_cost: "low" }` when they are inferred

## Override pattern

After assembling the scope contract, ask:

> This is the recommended skateboard. You can:
> 1. Proceed with this skateboard for the PRD.
> 2. Add features to v1 that you consider essential even if they fall outside the recommendation. Which?
> 3. Rewrite the skateboard from scratch.

Behavior:

- Option 1 -> proceed with the recommendation
- Option 2 -> capture each added feature plus one follow-up `Why is this essential for v1?`
- Option 3 -> capture the rewritten scope and note in `## Scope Decisions` that the recommendation was rejected

## Step 2.5 -> Optional scope-contract export

Prompt:

> Want me to save this scope contract as a standalone file? Useful to share with stakeholders without sending the full PRD.

Options:

1. Yes, save to `projects/{slug}/scope-contract.md`
2. No, keep it inside the PRD only
