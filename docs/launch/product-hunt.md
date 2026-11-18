# Product Hunt launch kit

Everything to paste into the Product Hunt submission form, plus the plan around launch day. Submitting is done by the
maker from their own Product Hunt account; nothing here has been posted.

Launch: **Wednesday 2026-11-18 at 00:01 PST (08:01 UTC)**, self-hunted, set by the maker. Goal: GitHub stars and installs
rather than rank alone.

## Form fields

| Field | Value |
|---|---|
| Name | `cowtree` |
| Tagline (53/60) | `Git worktrees that cost no disk until you edit a file` |
| Link | `https://paakofiaidoo.github.io/cowtree/` |
| GitHub | `https://github.com/paakofiaidoo/cowtree` |
| Pricing | Free (open source, MIT) |
| Topics | Developer Tools, Open Source, GitHub, Artificial Intelligence, Mac |
| Thumbnail (240×240) | `docs/launch/gallery/thumbnail.png` |
| Shoutouts | Claude Code, Git, Homebrew |

**Description (237/260)**

> Git worktrees made of APFS clonefile copies of your checkout, node_modules included. Run many Claude Code, Codex or Cursor sessions on one repo at near-zero disk cost; clear resets build files to the base. CLI, Homebrew, MCP server. MIT.

## Gallery (1270×760, in this order)

The first image is also the social preview, so it carries the pitch and real output. Sources are the HTML files in
`docs/launch/src/`; re-render with `docs/launch/src/render.sh` (headless Chrome).

| # | File | Shows |
|---|---|---|
| 1 | `docs/launch/gallery/1-hero.png` | Pitch, `brew install`, real `cowtree ls`: three worktrees of a 301 MB checkout owning 8–12 KB each |
| 2 | `docs/launch/gallery/2-proof.png` | `du`, `df` before and after three `cowtree add`s (free space unchanged), one edit, `cowtree status` owning 12 KB |
| 3 | `docs/launch/gallery/3-how.png` | Block diagram: clones share the base's blocks, only written blocks are owned; the four steps |
| 4 | `docs/launch/gallery/4-compare.png` | Why cowtree, compared by approach rather than by product: plain worktree, second clone, copy-on-write copy of the whole directory, worktree manager with copy-on-write for ignored files only |
| 5 | `docs/launch/gallery/5-agents.png` | Claude Code plugin install, `/cowtree-*` commands (including `/cowtree-clear`), MCP tools |

Video is optional; if you record one, keep it under 60 seconds: `cowtree add` three times, `cowtree ls`, open the
worktree, run the app without reinstalling dependencies, `cowtree sweep`.

## Maker's first comment

Post this the minute the launch goes live.

> Hi Product Hunt 👋 I'm Paa Kofi, and I built cowtree because disk space became the limit on how many AI coding sessions I could run.
>
> I run several Claude Code and Codex sessions on the same repository, one branch each. Each needs its own working tree, and `git worktree add` gives you that, but every worktree is a full copy of every file, and `node_modules` has to be reinstalled in each. On a nearly full laptop that stopped me at two or three sessions.
>
> cowtree builds the worktree out of APFS `clonefile` copies of the main checkout instead (reflink on btrfs/XFS), ignored build directories included. A 704 MB checkout becomes a 3.5 MB worktree, and editing a file costs that file. No FUSE, no daemon: a few hundred lines of bash and a small Python helper, so editors, compilers and git see ordinary files.
>
> Unlike a second clone or a copy of the whole directory, it stays one repository: a real linked worktree with shared history, one branch per tree. When a worktree's build output drifts, `cowtree clear` throws the ignored files away and re-clones them from the base; tracked files and your edits are never touched.
>
> It also records which branch lives in which worktree in git config (`cowtree which`, `cowtree branches`), sweeps worktrees whose PRs merged (squash merges too), turns your existing plain worktrees into clones (`cowtree adopt`), and ships as a Claude Code plugin and an MCP server so agents use it instead of `git worktree add`.
>
> Install: `brew install paakofiaidoo/tap/cowtree`
>
> Two things I'd love feedback on: the Linux reflink backend is written but hasn't been exercised on a real btrfs/XFS box yet, and I'd like to know which agent setups (Cursor, Windsurf, Zed, Cline) you'd want first-class support for.

## Launch-day checklist

**Before 00:01 PST**
- [ ] Run through the install paths once: `brew install paakofiaidoo/tap/cowtree`, the curl installer, `/plugin install cowtree`.
- [ ] Have the X thread and LinkedIn post from `docs/ANNOUNCE.md` ready with the Product Hunt link.
- [ ] A short personal note to people who would genuinely want the tool: what it is and that it is live today; no ask to upvote (vote requests break Product Hunt's rules).

**Launch day (Wednesday 2026-11-18, times in PST)**
- [ ] 00:01: launch goes live; post the maker comment above.
- [ ] 00:05: post the X thread and the LinkedIn post with the Product Hunt link; add the link to the README and the site's hero for the day.
- [ ] 00:15–04:00: message the support list one by one; reply to every comment within minutes.
- [ ] 06:00: Show HN from `docs/ANNOUNCE.md` (link the GitHub repo, not Product Hunt).
- [ ] 08:00: r/ClaudeAI, r/git, r/ChatGPTCoding with the Reddit copy in `docs/ANNOUNCE.md`.
- [ ] Every 2–3 hours: progress update on X; answer comments on Product Hunt, HN and Reddit.
- [ ] 23:00: thank-you post; note the final rank, stars gained and installs.

**After**
- [ ] Add the Product Hunt badge to the site and README if it places.
- [ ] Same week: DevHunt (devhunt.org), Peerlist, Indie Hackers. Following week: AlternativeTo (as an alternative to `git worktree`), SaaSHub, Console.dev newsletter submission.
- [ ] Turn launch-day questions into README FAQ entries and issues.
- [ ] Add the Pages property to Google Search Console and submit `sitemap.xml`.

**Numbers**: visits, countries and referrers for the site are at https://cowtree.goatcounter.com (the maker's login; the
site counts with GoatCounter, no cookies). The repository's own views, clones and referrers are under GitHub Insights > Traffic.

## Don'ts
- No "please upvote" in any message or post, no vote exchanges, no new accounts asked to vote.
- No claims beyond the README: Linux reflink is "written, not yet exercised on a Linux box".
