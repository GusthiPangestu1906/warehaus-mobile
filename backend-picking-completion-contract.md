# Backend Contract: Picking Completion Display

Dokumen ini menjelaskan perubahan yang dibutuhkan dari backend agar tampilan mobile setelah scan zone/shelf terakhir sesuai desain Figma.

## Masalah Saat Ini

Saat semua picking task selesai, backend mengembalikan state completed/packing, tetapi tidak selalu mengirim data task terakhir.

Contoh response yang menyebabkan masalah di mobile:

```json
{
  "salesOrderId": 10,
  "stage": "Packing",
  "isStageCompleted": true,
  "progress": {
    "completedItems": 1,
    "totalItems": 1
  },
  "task": null,
  "nextTask": null
}
```

Jika mobile membuka ulang page atau app melakukan restart, state lokal `lastVerifiedTask` hilang. Akibatnya mobile tidak tahu produk dan lokasi terakhir yang harus ditampilkan, sehingga fallback bisa muncul sebagai teks seperti `Picking selesai.`.

## Tampilan Yang Diharapkan Mobile

Setelah scan zone/shelf terakhir berhasil, mobile tetap harus menampilkan ringkasan task terakhir:

```text
SKU: 994-XQ-2
Heavy Duty Steel Cog Assembly V2

ZONE B - AISLE 02 - SHELF 03
Verified
```

Tombol bawah tetap `Done`, dan saat ditekan user lanjut ke Packing.

## Perubahan Response Yang Dibutuhkan

Saat picking selesai, backend sebaiknya tetap mengirim data task terakhir melalui field `lastCompletedTask`.

Endpoint:

```http
POST /api/outbound/sales-orders/{salesOrderId}/picking/items/{salesOrderItemId}/complete
```

Response ketika semua picking selesai:

```json
{
  "salesOrderId": 10,
  "stage": "Packing",
  "isStageCompleted": true,
  "nextStage": "Packing",
  "progress": {
    "completedItems": 1,
    "totalItems": 1,
    "completedQuantity": 1,
    "totalQuantity": 1
  },
  "lastCompletedTask": {
    "salesOrderItemId": 55,
    "productId": 2,
    "sku": "994-XQ-2",
    "productName": "Heavy Duty Steel Cog Assembly V2",
    "requiredQty": 1,
    "unitOfMeasure": "Items",
    "shelfId": 7,
    "shelfCode": "ZONE B - AISLE 02 - SHELF 03",
    "shelfQrCode": "SHELF-7"
  },
  "nextTask": null
}
```

## Idempotent Get Next Task

Endpoint `GET /api/outbound/sales-orders/{salesOrderId}/picking/next-task` juga perlu mengirim `lastCompletedTask` jika picking sudah selesai.

Response yang diharapkan:

```json
{
  "salesOrderId": 10,
  "stage": "Packing",
  "isStageCompleted": true,
  "nextStage": "Packing",
  "progress": {
    "completedItems": 1,
    "totalItems": 1,
    "completedQuantity": 1,
    "totalQuantity": 1
  },
  "task": null,
  "lastCompletedTask": {
    "salesOrderItemId": 55,
    "productId": 2,
    "sku": "994-XQ-2",
    "productName": "Heavy Duty Steel Cog Assembly V2",
    "requiredQty": 1,
    "unitOfMeasure": "Items",
    "shelfId": 7,
    "shelfCode": "ZONE B - AISLE 02 - SHELF 03",
    "shelfQrCode": "SHELF-7"
  }
}
```

## Field Wajib

`lastCompletedTask` wajib memiliki field berikut:

| Field | Tipe | Keterangan |
| --- | --- | --- |
| `salesOrderItemId` | number | ID item SO yang selesai dipicking |
| `productId` | number | ID produk |
| `sku` | string | Ditampilkan di banner produk |
| `productName` | string | Ditampilkan di banner produk |
| `requiredQty` | number | Jumlah item yang dipick |
| `unitOfMeasure` | string | Satuan item |
| `shelfId` | number | ID shelf yang discan |
| `shelfCode` | string | Ditampilkan di card lokasi verified |
| `shelfQrCode` | string | QR/code shelf untuk validasi scan |

## Catatan Implementasi Backend

- `lastCompletedTask` harus berasal dari task yang baru saja diselesaikan, bukan dari item pertama secara asal.
- Jika endpoint dipanggil ulang setelah picking selesai, backend tetap harus bisa mengembalikan `lastCompletedTask` dari database.
- `progress.completedItems` harus sama dengan `progress.totalItems` saat `isStageCompleted: true`.
- `stage` boleh bernilai `Packing` setelah picking selesai, tetapi tetap sertakan `isStageCompleted: true`.
- `nextTask` sebaiknya `null` saat semua picking sudah selesai.

## Alasan Dibutuhkan

Mobile perlu data ini untuk mempertahankan UI selesai scan sesuai desain, bahkan setelah hot restart, refresh page, atau user membuka ulang Sales Order yang sudah masuk stage Packing.

Tanpa `lastCompletedTask`, mobile hanya bisa menebak dari data Sales Order item, dan lokasi bisa tidak akurat jika satu item punya beberapa lokasi atau backend memilih shelf tertentu.
