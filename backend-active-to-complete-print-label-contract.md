# Backend Contract: Outbound Active To Complete + Print Label

Dokumen ini merangkum kebutuhan backend agar flow outbound mobile bisa berjalan tanpa error dari status `Active` sampai `Completed`, lalu print label.

Tanggal update: 15 Juni 2026

## Tujuan Flow

Flow yang diharapkan:

```text
Sales Order Active
-> Start Picking
-> Scan shelf / complete picking item
-> Masuk Packing
-> Scan barcode item / verify packing item
-> Complete & Print Label
-> Sales Order Completed
-> Label tersedia
```

## Masalah Yang Sedang Terjadi

### 1. Picking complete gagal 404

Log mobile:

```text
Picking Task untuk Sales Order ini tidak ditemukan.
```

Penyebab:

- Mobile bisa menampilkan task dari `suggestedLocations`.
- Tetapi backend belum membuat record/state `Picking Task`.
- Saat mobile scan shelf dan memanggil complete picking, backend tidak menemukan task internal.

Backend perlu memastikan endpoint start picking membuat task yang bisa diselesaikan.

### 2. Packing complete gagal 409

Response backend:

```json
{
  "status": 409,
  "detail": "Semua item harus selesai diverifikasi packing sebelum Sales Order diselesaikan.",
  "errors": [
    "Semua item harus selesai diverifikasi packing sebelum Sales Order diselesaikan."
  ]
}
```

Penyebab:

- Mobile scan barcode item sudah berhasil secara UI.
- Backend belum menerima atau belum menyimpan status verify packing item.
- Saat `packing/complete` dipanggil, backend masih menganggap ada item yang belum verified.

Backend perlu menyediakan endpoint verify/complete packing item dan menyimpan statusnya.

### 3. Packing complete pernah gagal 415

Log backend:

```text
POST /api/outbound/sales-orders/{id}/packing/complete -> 415 Unsupported Media Type
```

Penyebab:

- Backend mengharapkan JSON body/content-type.
- Mobile sekarang mengirim JSON body, tetapi backend tetap perlu menerima request minimal `{}` atau body `verifiedItems`.

## Endpoint Wajib

### 1. Get Sales Order Detail

```http
GET /api/outbound/sales-orders/{salesOrderId}
```

Response wajib mengirim data lengkap untuk picking, packing, detail SO, dan label.

Minimal response:

```json
{
  "id": 22,
  "soNumber": "SO-202606140001",
  "status": "Active",
  "isCompleted": false,
  "orderDate": "2026-06-14T00:00:00Z",
  "requiredDeliveryDate": "2026-06-15T00:00:00Z",
  "trackingNumber": "JNT123987456",
  "customerName": "Joe Doe",
  "companyName": "PT. Material Indo",
  "contactPerson": "Joe Doe",
  "phoneNumber": "08123456789",
  "shippingAddress": "Jl. Raya ITS",
  "provinceName": "Jawa Timur",
  "cityName": "Surabaya",
  "districtName": "Sukolilo",
  "postalCode": "60111",
  "courierName": "JNE Cargo",
  "note": "Catatan sales order",
  "totalOrderedQuantity": 2,
  "totalPickedItems": 0,
  "totalVerifiedItems": 0,
  "progressPercentage": 0,
  "labelAvailable": false,
  "items": [
    {
      "id": 27,
      "salesOrderItemId": 27,
      "productId": 2,
      "sku": "PRFM-MLK",
      "barcode": "989738782",
      "productName": "Parfum Malika",
      "qtyOrdered": 2,
      "qtyPicked": 0,
      "qtyVerified": 0,
      "unitOfMeasure": "PCS",
      "suggestedLocations": [
        {
          "shelfId": 1,
          "shelfCode": "ABC-LLC-1-1",
          "shelfQrCode": "ABC-LLC-1-1",
          "zoneCode": "ABC-LLC",
          "zoneName": "Kosmetik",
          "aisle": 1,
          "availableQuantity": 18
        }
      ]
    }
  ]
}
```

Field wajib item:

| Field | Kegunaan |
| --- | --- |
| `id` / `salesOrderItemId` | Dipakai untuk complete picking dan verify packing |
| `productId` | Identitas product |
| `sku` | Tampilan UI dan fallback scan |
| `barcode` | Validasi scan item saat packing |
| `qtyOrdered` | Expected qty |
| `unitOfMeasure` | Satuan UI |
| `suggestedLocations[].shelfId` | Complete picking |
| `suggestedLocations[].shelfCode` atau `shelfQrCode` | Validasi scan shelf |

Catatan penting:

- Barcode harus ada di item Sales Order, bukan hanya di endpoint product.
- Jika product barcode diperbarui, pastikan detail SO mengirim barcode terbaru atau snapshot yang benar.

## Picking Flow

### 2. Start Picking

```http
POST /api/outbound/sales-orders/{salesOrderId}/picking/start
Content-Type: application/json
```

Request boleh kosong:

```json
{}
```

Backend harus:

- Membuat picking task untuk Sales Order jika belum ada.
- Idempotent: jika task sudah ada, jangan error; kembalikan task yang aktif.
- Mengambil lokasi dari stock/shelf yang tersedia.
- Mengurangi/mengunci stok sesuai aturan backend jika diperlukan.

Response sukses:

```json
{
  "salesOrderId": 22,
  "stage": "Picking",
  "isStageCompleted": false,
  "progress": {
    "completedItems": 0,
    "totalItems": 1,
    "completedQuantity": 0,
    "totalQuantity": 2
  },
  "task": {
    "salesOrderItemId": 27,
    "productId": 2,
    "sku": "PRFM-MLK",
    "productName": "Parfum Malika",
    "requiredQty": 2,
    "unitOfMeasure": "PCS",
    "shelfId": 1,
    "shelfCode": "ABC-LLC-1-1",
    "shelfQrCode": "ABC-LLC-1-1"
  }
}
```

### 3. Get Next Picking Task

```http
GET /api/outbound/sales-orders/{salesOrderId}/picking/next-task
```

Backend harus:

- Mengembalikan task picking aktif berikutnya.
- Jika belum ada task, boleh memanggil logic start secara idempotent atau return instruksi yang jelas.
- Jika picking selesai, return stage packing.

Response saat masih ada task:

```json
{
  "salesOrderId": 22,
  "stage": "Picking",
  "isStageCompleted": false,
  "progress": {
    "completedItems": 0,
    "totalItems": 1
  },
  "task": {
    "salesOrderItemId": 27,
    "productId": 2,
    "sku": "PRFM-MLK",
    "productName": "Parfum Malika",
    "requiredQty": 2,
    "unitOfMeasure": "PCS",
    "shelfId": 1,
    "shelfCode": "ABC-LLC-1-1",
    "shelfQrCode": "ABC-LLC-1-1"
  }
}
```

### 4. Complete Picking Item

```http
POST /api/outbound/sales-orders/{salesOrderId}/picking/items/{salesOrderItemId}/complete
Content-Type: application/json
```

Request:

```json
{
  "shelfId": 1,
  "pickedQty": 2
}
```

Backend harus:

- Memastikan picking task ada.
- Memastikan shelf sesuai task.
- Menandai `qtyPicked`.
- Jika semua item selesai picking, pindahkan stage ke `Packing` atau status internal yang ekuivalen.

Response ketika picking selesai:

```json
{
  "salesOrderId": 22,
  "stage": "Packing",
  "isStageCompleted": true,
  "progress": {
    "completedItems": 1,
    "totalItems": 1,
    "completedQuantity": 2,
    "totalQuantity": 2
  },
  "lastCompletedTask": {
    "salesOrderItemId": 27,
    "productId": 2,
    "sku": "PRFM-MLK",
    "productName": "Parfum Malika",
    "requiredQty": 2,
    "unitOfMeasure": "PCS",
    "shelfId": 1,
    "shelfCode": "ABC-LLC-1-1",
    "shelfQrCode": "ABC-LLC-1-1"
  },
  "nextTask": null
}
```

## Packing Flow

### 5. Start Packing

Opsional tetapi direkomendasikan:

```http
POST /api/outbound/sales-orders/{salesOrderId}/packing/start
Content-Type: application/json
```

Request:

```json
{}
```

Backend harus:

- Memastikan Sales Order sudah selesai picking.
- Membuat packing task per item jika belum ada.
- Idempotent.

Response:

```json
{
  "salesOrderId": 22,
  "stage": "Packing",
  "isStageCompleted": false,
  "progress": {
    "completedItems": 0,
    "totalItems": 1,
    "completedQuantity": 0,
    "totalQuantity": 2
  },
  "task": {
    "salesOrderItemId": 27,
    "productId": 2,
    "sku": "PRFM-MLK",
    "barcode": "989738782",
    "productName": "Parfum Malika",
    "expectedQty": 2,
    "unitOfMeasure": "PCS"
  }
}
```

### 6. Scan Barcode Item Di Mobile

Alur mobile dibuat mirip flow QC inbound:

- User scan barcode item memakai `WHScannerPage` dari core UI.
- Mobile mencocokkan hasil scan dengan `items[].barcode`.
- Jika cocok, item ditandai verified secara lokal.
- Mobile belum mengirim request ke backend pada tahap scan item.
- Backend dipanggil sekali saat tombol `Complete & Print Label` ditekan.

Konsekuensinya:

- `items[].barcode` wajib dikirim di detail Sales Order.
- Barcode harus sama persis dengan barcode product yang ditempel pada barang.
- Endpoint complete packing harus bisa menerima daftar item yang sudah diverifikasi mobile melalui body `verifiedItems`.

Endpoint verify per item bersifat opsional. Jika backend tetap ingin menyimpan verify per item sebelum complete, backend boleh menyediakan:

```http
POST /api/outbound/sales-orders/{salesOrderId}/packing/items/{salesOrderItemId}/complete
Content-Type: application/json
```

Request:

```json
{
  "packedQty": 2
}
```

atau:

```http
POST /api/outbound/sales-orders/{salesOrderId}/packing/items/{salesOrderItemId}/verify
Content-Type: application/json
```

Request:

```json
{
  "verifiedQty": 2,
  "packedQty": 2
}
```

Namun flow mobile yang diharapkan sekarang tidak bergantung pada endpoint verify per item tersebut.

Jika endpoint opsional ini dibuat, backend harus:

- Memastikan item memang bagian dari Sales Order.
- Memastikan item sudah picked.
- Menandai item sebagai verified/packed di database.
- Mengupdate `qtyVerified` atau field packing equivalent.
- Mengembalikan progress packing.

Response sukses:

```json
{
  "salesOrderId": 22,
  "salesOrderItemId": 27,
  "productId": 2,
  "sku": "PRFM-MLK",
  "barcode": "989738782",
  "productName": "Parfum Malika",
  "verifiedQty": 2,
  "unitOfMeasure": "PCS",
  "isVerified": true,
  "progress": {
    "completedItems": 1,
    "totalItems": 1,
    "completedQuantity": 2,
    "totalQuantity": 2
  }
}
```

### 7. Complete Packing / Finalize Sales Order

```http
POST /api/outbound/sales-orders/{salesOrderId}/packing/complete
Content-Type: application/json
```

Request:

```json
{
  "verifiedItems": [
    {
      "salesOrderItemId": 27,
      "packedQty": 2
    }
  ]
}
```

Backend harus:

- Menerima `verifiedItems` dari mobile.
- Memastikan semua item Sales Order ada di `verifiedItems`.
- Memastikan setiap `salesOrderItemId` memang bagian dari Sales Order tersebut.
- Memastikan `packedQty` sesuai dengan jumlah yang harus dipacking.
- Menandai item sebagai verified/packed di database dalam transaksi yang sama.
- Mengubah status Sales Order menjadi `Completed`.
- Set `isCompleted: true`.
- Set `labelAvailable: true`.
- Set `completedAt`.

Catatan penting:

- Jangan hanya mengecek status verified yang sudah ada di database sebelum membaca body `verifiedItems`.
- Jika backend ingin tetap menolak karena ada item belum verified, backend harus menandai item dari `verifiedItems` terlebih dahulu, lalu baru validasi semua item.
- Ini mencegah error `409 Semua item harus selesai diverifikasi packing...` setelah mobile sudah berhasil scan semua item.

Response sukses:

```json
{
  "salesOrderId": 22,
  "status": "Completed",
  "stage": "Completed",
  "isCompleted": true,
  "labelAvailable": true,
  "completedAt": "2026-06-15T00:00:00Z",
  "progress": {
    "completedItems": 1,
    "totalItems": 1,
    "completedQuantity": 2,
    "totalQuantity": 2
  }
}
```

## Print Label

### 8. Get Label Data

```http
GET /api/outbound/sales-orders/{salesOrderId}/label
```

Backend harus:

- Return `200` hanya jika Sales Order sudah `Completed`.
- Return `409` jika belum completed dengan pesan jelas.
- Mengirim data lengkap untuk render label A4.

Response sukses:

```json
{
  "salesOrderId": 22,
  "createdAt": "2026-06-14T00:00:00Z",
  "printedAt": "2026-06-15T00:00:00Z",
  "soNumber": "SO-14062026-22",
  "slaDate": "2026-06-15T00:00:00Z",
  "trackingNumber": "JNT123987456",
  "companyName": "PT. Material Indo",
  "customerName": "Joe Doe",
  "courierName": "JNE Cargo",
  "address": "Jl. Raya ITS",
  "province": "Jawa Timur",
  "city": "Surabaya",
  "district": "Sukolilo",
  "postalCode": "60111",
  "note": "Catatan sales order",
  "items": [
    {
      "no": 1,
      "salesOrderItemId": 27,
      "productId": 2,
      "sku": "PRFM-MLK",
      "productName": "Parfum Malika",
      "qty": 2,
      "unitOfMeasure": "PCS"
    }
  ],
  "signatureLabel": "Supervisor"
}
```

### 9. Get Label PDF

Backend sekarang juga menyediakan output PDF siap print:

```http
GET /api/outbound/sales-orders/{salesOrderId}/label.pdf
Accept: application/pdf
```

Response sukses:

- Status `200`.
- Header `content-type: application/pdf`.
- Header `content-disposition` berisi filename, contoh `sales-order-24-label.pdf`.
- Body berupa file PDF A4 sesuai design label.

Contoh endpoint yang sudah berhasil dicek:

```http
GET /api/outbound/sales-orders/24/label.pdf
```

Catatan mobile:

- Tombol `Complete & Print Label` saat ini menyelesaikan packing dulu.
- Setelah status SO `Completed`, mobile bisa membuka/download PDF dari endpoint `label.pdf`.
- Jika backend complete berhasil tetapi response mobile sempat gagal, mobile akan cek ulang detail SO. Jika status backend sudah `Completed`, mobile tetap menampilkan sukses.

## Status Yang Diharapkan

| Kondisi | `status` | `isCompleted` | `labelAvailable` |
| --- | --- | --- | --- |
| Baru dibuat, belum tracking | `Queued` | `false` | `false` |
| Tracking sudah diisi / picking berjalan | `Active` atau `Picking` | `false` | `false` |
| Picking selesai, packing berjalan | `Active` atau `Packing` | `false` | `false` |
| Packing selesai | `Completed` | `true` | `true` |

Mobile saat ini tetap menampilkan `Picking` dan `Packing` sebagai flow `Active`, tetapi detail SO completed butuh `Completed`.

## Acceptance Criteria

Backend dianggap siap jika semua poin ini terpenuhi:

- `GET /api/outbound/sales-orders/{id}` mengirim `items[].barcode`, `items[].id/salesOrderItemId`, dan `suggestedLocations`.
- `POST /picking/start` idempotent dan membuat task picking.
- `GET /picking/next-task` mengembalikan task aktif atau state selesai yang jelas.
- `POST /picking/items/{salesOrderItemId}/complete` tidak return 404 jika task sudah distart.
- Setelah semua picking selesai, SO masuk stage packing.
- `POST /packing/complete` menerima body `verifiedItems`.
- `POST /packing/complete` menandai semua item di `verifiedItems` sebagai verified/packed sebelum mengubah SO menjadi completed.
- `POST /packing/complete` tidak return 409 jika semua item sudah ada di body `verifiedItems` dan qty valid.
- `POST /packing/complete` menerima `Content-Type: application/json`.
- Setelah packing complete, SO detail mengembalikan `status: "Completed"`, `isCompleted: true`, dan `labelAvailable: true`.
- `GET /label` return 200 setelah SO completed.
- `GET /label.pdf` return 200 PDF setelah SO completed.

## Error Yang Perlu Dihindari

### Picking task 404

Jangan return:

```json
{
  "status": 404,
  "detail": "Picking Task untuk Sales Order ini tidak ditemukan."
}
```

Jika belum ada task, backend sebaiknya membuat task lewat `picking/start`, atau `next-task` bersifat idempotent.

### Packing verify 409

Jangan sampai `packing/complete` return:

```json
{
  "status": 409,
  "detail": "Semua item harus selesai diverifikasi packing sebelum Sales Order diselesaikan."
}
```

Mobile sekarang mengirim item verified di body `packing/complete`.

Backend harus membaca body:

```json
{
  "verifiedItems": [
    {
      "salesOrderItemId": 27,
      "packedQty": 2
    }
  ]
}
```

Lalu backend menandai item sebagai verified/packed dan menyelesaikan Sales Order dalam satu transaksi.

### Unsupported media type 415

Pastikan endpoint POST menerima JSON request.

Mobile mengirim:

```http
Content-Type: application/json
```

Dengan body minimal:

```json
{}
```

atau body sesuai endpoint.
