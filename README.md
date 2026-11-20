# Our Date List — Date Wishlist V3

This project carries forward the supplied V3 HTML and its approved visual design. It uses Vite for local development and GitHub Pages for hosting, and Supabase for shared storage, sign-in, and live updates.

## Included features

- All, To do, and Done wishlist filters, with animated completion.
- Separate Yayan and Alca reviews with five fixed 1–5 ratings. Overall is the arithmetic mean, rounded to one decimal place.
- Saved review previews and an Edit review flow.
- A separate New wish form, plus an activity history for additions, completions, reopenings, and deletions.
- Floating geometric background with collisions, cursor interaction, and reduced-motion support.
- Supabase Realtime synchronization between signed-in devices.

## Set up Supabase

1. Create a Supabase project and open its SQL Editor.
2. Run the contents of [`supabase.sql`](./supabase.sql).
3. In **Authentication → Users**, choose **Add user → Create new user** and create one email/password account for each person. Let each person choose and enter their own password; mark the user confirmed if the dashboard offers that option.
4. In the Auth settings, turn off **Allow new users to sign up**. The two accounts you created can still sign in.
5. In the SQL Editor, find their user IDs with `select id, email from auth.users;`. Add only the two intended accounts to `public.members` (replace the UUIDs):

   ```sql
   insert into public.members (user_id, name) values
     ('YAYAN_AUTH_USER_UUID', 'yayan'),
     ('ALCA_AUTH_USER_UUID', 'alca');
   ```

6. Copy the project URL and **publishable key** from the Supabase project’s Connect dialog or Settings → API Keys. Never use a secret/service-role key in this website.
7. Copy `.env.example` to `.env.local`, then fill in `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY` if you also want to run it locally.

Both people sign in at the same website link. Approved members can add, complete, reopen, and delete wishes. Each account is tied to its matching reviewer slot, so Yayan can edit Yayan’s review and Alca can edit Alca’s. Row-level security checks membership and reviewer identity in the database; the login form does not let a visitor choose someone else’s name.

## Run locally

Install Node.js 20.19+ or 22.12+, then run:

```sh
npm install
npm run dev
```

Vite shows the local URL. Sign in with either Supabase account.

## Upload the source to GitHub

1. Download and extract the ZIP. Open the inner `date-wishlist-v3` folder.
2. Create a GitHub repository named `date-wishlist-v3`, select branch `main`, and add the starter README so the repository has an initial commit. If you use GitHub Free, choose **Public**; Pages requires a public source repository on that plan.
3. In GitHub Desktop, clone the empty repository. Copy the **contents** of the extracted folder into the cloned repository root (including `.github`, `.gitignore`, and `.env.example`; do not copy `.env.local`).
4. Commit the files to `main` and push to GitHub.

## Deploy to GitHub Pages

1. In repository **Settings → Secrets and variables → Actions**, add these repository secrets:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_PUBLISHABLE_KEY`
2. In **Settings → Pages**, set the publishing source to **GitHub Actions**.
3. Push to `main` or run **Deploy to GitHub Pages** from the Actions tab. GitHub will show the live site URL in the deployment.

The workflow builds the Vite project and selects the correct URL path for a repository site automatically. GitHub Pages sites are public on the internet, including when the source repository is private. On GitHub Free, the source repository must be public to use Pages; account plans with private Pages support can keep the source repository private. The site still requires a member account to view or change wishlist data.

## Data model

- `wishes`: activities, status, type, note, and completion date.
- `rv`: one review per activity per reviewer, including the five ratings and memo.
- `activity_history`: a chronological record of list changes.

The database receives the publishable key in the browser; row-level security is what protects the data. The SQL grants access only to the two accounts listed in `members`, and each person can edit only their own review. Never put a Supabase secret/service-role key in this website or its GitHub repository.
