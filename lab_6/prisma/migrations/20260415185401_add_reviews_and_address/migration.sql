-- AlterTable
ALTER TABLE "people" ADD COLUMN     "address" VARCHAR(255);

-- CreateTable
CREATE TABLE "medical_review" (
    "review_id" SERIAL NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "patient_id" INTEGER NOT NULL,

    CONSTRAINT "medical_review_pkey" PRIMARY KEY ("review_id")
);

-- AddForeignKey
ALTER TABLE "medical_review" ADD CONSTRAINT "medical_review_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "patient"("patient_id") ON DELETE RESTRICT ON UPDATE CASCADE;
