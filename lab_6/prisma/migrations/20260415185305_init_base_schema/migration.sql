-- CreateEnum
CREATE TYPE "patient_gender" AS ENUM ('чоловік', 'жінка');

-- CreateEnum
CREATE TYPE "staff_type" AS ENUM ('спеціаліст', 'асистент');

-- CreateTable
CREATE TABLE "people" (
    "people_id" SERIAL NOT NULL,
    "first_name" VARCHAR(25) NOT NULL,
    "last_name" VARCHAR(32) NOT NULL,
    "birth_date" DATE NOT NULL,
    "phone_number" CHAR(12) NOT NULL,
    "email" VARCHAR(64) NOT NULL,

    CONSTRAINT "people_pkey" PRIMARY KEY ("people_id")
);

-- CreateTable
CREATE TABLE "patient" (
    "patient_id" SERIAL NOT NULL,
    "gender" "patient_gender" NOT NULL,
    "people_id" INTEGER NOT NULL,

    CONSTRAINT "patient_pkey" PRIMARY KEY ("patient_id")
);

-- CreateTable
CREATE TABLE "doctor" (
    "doctor_id" SERIAL NOT NULL,
    "staff_type" "staff_type" NOT NULL DEFAULT 'спеціаліст',
    "people_id" INTEGER NOT NULL,

    CONSTRAINT "doctor_pkey" PRIMARY KEY ("doctor_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "people_email_key" ON "people"("email");

-- CreateIndex
CREATE UNIQUE INDEX "patient_people_id_key" ON "patient"("people_id");

-- CreateIndex
CREATE UNIQUE INDEX "doctor_people_id_key" ON "doctor"("people_id");

-- AddForeignKey
ALTER TABLE "patient" ADD CONSTRAINT "patient_people_id_fkey" FOREIGN KEY ("people_id") REFERENCES "people"("people_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "doctor" ADD CONSTRAINT "doctor_people_id_fkey" FOREIGN KEY ("people_id") REFERENCES "people"("people_id") ON DELETE RESTRICT ON UPDATE CASCADE;
