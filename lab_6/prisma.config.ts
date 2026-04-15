import { defineConfig } from '@prisma/config';

export default defineConfig({
  datasource: {
    url: 'postgresql://postgres:password123@127.0.0.1:5433/postgres?schema=public',
  },
});