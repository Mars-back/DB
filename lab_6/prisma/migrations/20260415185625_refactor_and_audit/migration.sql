/*
  Warnings:

  - You are about to drop the column `phone_number` on the `people` table. All the data in the column will be lost.
  - Added the required column `contact_info` to the `people` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updated_at` to the `people` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "people" DROP COLUMN "phone_number",
ADD COLUMN     "contact_info" VARCHAR(50) NOT NULL,
ADD COLUMN     "updated_at" TIMESTAMP(3) NOT NULL;
