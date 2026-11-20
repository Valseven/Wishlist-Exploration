import { defineConfig } from 'vite';

const [owner, repository] = (process.env.GITHUB_REPOSITORY || '').split('/');
const isAccountSite = repository === `${owner}.github.io`;
const pagesBase = process.env.GITHUB_ACTIONS === 'true' && repository && !isAccountSite
  ? `/${repository}/`
  : '/';

export default defineConfig({
  base: process.env.VITE_BASE_PATH || pagesBase,
});
