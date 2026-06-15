 # Outbound Backend Flow Reference

Dokumen ini adalah patokan integrasi backend untuk flow Outbound di WareHaus Mobile. Polanya dibuat mengikuti flow Inbound `QC + Put Away`, tetapi disesuaikan untuk `Sales Order`, `Picking`, dan `Packing`.

## Tujuan

Mobile perlu mendapatkan task outbound satu per satu dari backend, melakukan scan di mobile, lalu mengirim hasil selesai per item/task ke backend.

Backend menjadi source of truth untuk:

- Status Sales Order.
- Item berikutnya yang harus diproses.
- Progress picking.
- Progress packing.
- Tracking number.
- Final status completed.

Mobile menjadi tempat untuk:

- Scan QR shelf/location saat picking.
- Scan barcode item saat packing.
- Validasi hasil scan terhadap data task dari backend.
- Mengirim status selesai ke backend.

## Mapping Dari Inbound Ke Outbound

| Inbound | Outbound |
| --- | --- |
| `PoId` | `SalesOrderId` |
| `PoItemId` | `SalesOrderItemId` |
| QC item | Packing item |
| Put Away task | Picking location task |
| Scan QC / Put Away | Scan shelf saat picking, scan barcode saat packing |
| Selesai per item | Complete picking item / complete packing item |
| PO selesai | Sales Order completed / ready to ship |

## Status Yang Disarankan

Backend boleh memakai status detail:

```text
Queued
Picking
Packing
Completed
```

Untuk kebutuhan card mobile, status bisa dimapping:

```text
Queued    = belum mulai / belum ada tracking number
Active    = sedang Picking atau Packing
Completed = semua packing selesai
```

## Flow Utama

1. Mobile mengirim `SalesOrderId` yang ingin diproses.
2. Backend mengembalikan task/item berikutnya.
3. Mobile melakukan scan sesuai stage.
4. Mobile mengirim status selesai untuk task/item tersebut.
5. Backend menyimpan progress dan mengembalikan task berikutnya.
6. Jika semua picking selesai, backend pindah ke stage `Packing`.
7. Jika semua packing selesai, backend pindah ke status `Completed`.

## Tracking Number

Tracking number perlu disimpan ke backend sebelum picking dimulai, supaya status Sales Order bisa berubah dari `Queued` ke `Active`.

### Update Tracking Number

```http
PATCH /api/outbound/sales-orders/{salesOrderId}/tracking
```

Request:

```json
{
  "trackingNumber": "JNT123987456"
}
```

Response:

```json
{
  "salesOrderId": 10,
  "trackingNumber": "JNT123987456",
  "status": "Picking",
  "viewStatus": "Active"
}
```

Catatan:

- Setelah tracking number tersimpan, mobile dapat menampilkan tombol `Start Picking`.
- Jika backend belum ingin langsung masuk `Picking`, boleh response `status: "Queued"` tetapi `viewStatus: "Active"` selama tracking number sudah ada.

## Picking Flow

Picking adalah proses mengambil barang dari shelf/location. Mobile scan QR shelf/location.

### Start / Get Next Picking Task

```http
POST /api/outbound/sales-orders/{salesOrderId}/picking/start
```

Atau jika ingin idempotent:

```http
GET /api/outbound/sales-orders/{salesOrderId}/picking/next-task
```

Response:

```json
{
  "salesOrderId": 10,
  "stage": "Picking",
  "progress": {
    "completedItems": 0,
    "totalItems": 4,
    "completedQuantity": 0,
    "totalQuantity": 230
  },
  "task": {
    "salesOrderItemId": 55,
    "productId": 2,
    "sku": "PRFM-MLK",
    "productName": "Parfum Malika",
    "requiredQty": 20,
    "unitOfMeasure": "PCS",
    "shelfId": 7,
    "shelfCode": "ZONE B - AISLE 02 - SHELF 03",
    "shelfQrCode": "SHELF-7"
  }
}
```

### Complete Picking Task

Mobile mengirim request ini setelah scan shelf/location benar.

```http
POST /api/outbound/sales-orders/{salesOrderId}/picking/items/{salesOrderItemId}/complete
```

Request:

```json
{
  "shelfId": 7,
  "pickedQty": 20
}
```

Response ketika masih ada task berikutnya:

```json
{
  "salesOrderId": 10,
  "stage": "Picking",
  "isStageCompleted": false,
  "progress": {
    "completedItems": 1,
    "totalItems": 4,
    "completedQuantity": 20,
    "totalQuantity": 230
  },
  "nextTask": {
    "salesOrderItemId": 56,
    "productId": 3,
    "sku": "395-9823",
    "productName": "White pepper",
    "requiredQty": 10,
    "unitOfMeasure": "BOX",
    "shelfId": 8,
    "shelfCode": "ZONE B - AISLE 02 - SHELF 04",
    "shelfQrCode": "SHELF-8"
  }
}
```

Response ketika semua picking selesai:

```json
{
  "salesOrderId": 10,
  "stage": "Packing",
  "isStageCompleted": true,
  "nextStage": "Packing",
  "progress": {
    "completedItems": 4,
    "totalItems": 4,
    "completedQuantity": 230,
    "totalQuantity": 230
  }
}
```

## Packing Flow

Packing adalah proses verifikasi barang sebelum label dicetak. Mobile scan barcode item.

### Start / Get Next Packing Task

```http
POST /api/outbound/sales-orders/{salesOrderId}/packing/start
```

Atau:

```http
GET /api/outbound/sales-orders/{salesOrderId}/packing/next-task
```

Response:

```json
{
  "salesOrderId": 10,
  "stage": "Packing",
  "progress": {
    "completedItems": 0,
    "totalItems": 4,
    "completedQuantity": 0,
    "totalQuantity": 230
  },
  "task": {
    "salesOrderItemId": 55,
    "productId": 2,
    "sku": "PRFM-MLK",
    "barcode": "989738782",
    "productName": "Parfum Malika",
    "expectedQty": 20,
    "unitOfMeasure": "PCS"
  }
}
```

### Complete Packing Task

Mobile mengirim request ini setelah scan barcode item benar.

```http
POST /api/outbound/sales-orders/{salesOrderId}/packing/items/{salesOrderItemId}/complete
```

Request:

```json
{
  "packedQty": 20
}
```

Response ketika masih ada item berikutnya:

```json
{
  "salesOrderId": 10,
  "stage": "Packing",
  "isStageCompleted": false,
  "progress": {
    "completedItems": 1,
    "totalItems": 4,
    "completedQuantity": 20,
    "totalQuantity": 230
  },
  "nextTask": {
    "salesOrderItemId": 56,
    "productId": 3,
    "sku": "395-9823",
    "barcode": "3959823",
    "productName": "White pepper",
    "expectedQty": 10,
    "unitOfMeasure": "BOX"
  }
}
```

Response ketika semua packing selesai:

```json
{
  "salesOrderId": 10,
  "stage": "Completed",
  "status": "Completed",
  "isCompleted": true,
  "progress": {
    "completedItems": 4,
    "totalItems": 4,
    "completedQuantity": 230,
    "totalQuantity": 230
  }
}
```

## Sales Order List Response

Endpoint list saat ini:

```http
GET /api/outbound/sales-orders
```

Mobile membutuhkan field berikut agar card bisa berpindah status dengan benar:

```json
{
  "id": 10,
  "soNumber": "SO-202606130001",
  "customerName": "Customer Name",
  "trackingNumber": "JNT123987456",
  "status": "Packing",
  "totalOrderedQuantity": 230,
  "totalPickedItems": 230,
  "totalVerifiedItems": 90,
  "progressPercentage": 39.13,
  "isCompleted": false,
  "items": []
}
```

Mapping mobile:

- `status = "Queued"` dan `trackingNumber = null` -> card `Queued`.
- `status = "Picking"` -> card `Active`, progress `Picking Up Progress`.
- `status = "Packing"` -> card `Active`, progress `Packing Progress`.
- `status = "Completed"` atau `isCompleted = true` -> card `Completed`.

## Error Response Yang Disarankan

Barcode atau QR tidak cocok sebaiknya tetap divalidasi di mobile. Tetapi backend tetap perlu menjaga data agar tidak ada complete task yang salah.

Contoh response:

```json
{
  "message": "Shelf does not match the assigned picking task.",
  "code": "OUTBOUND_PICKING_SHELF_MISMATCH"
}
```

```json
{
  "message": "Item barcode does not match the assigned packing task.",
  "code": "OUTBOUND_PACKING_BARCODE_MISMATCH"
}
```

## Minimum Endpoint Yang Dibutuhkan Mobile

```text
GET   /api/outbound/sales-orders
GET   /api/outbound/sales-orders/{salesOrderId}
PATCH /api/outbound/sales-orders/{salesOrderId}/tracking

POST  /api/outbound/sales-orders/{salesOrderId}/picking/start
GET   /api/outbound/sales-orders/{salesOrderId}/picking/next-task
POST  /api/outbound/sales-orders/{salesOrderId}/picking/items/{salesOrderItemId}/complete

POST  /api/outbound/sales-orders/{salesOrderId}/packing/start
GET   /api/outbound/sales-orders/{salesOrderId}/packing/next-task
POST  /api/outbound/sales-orders/{salesOrderId}/packing/items/{salesOrderItemId}/complete
```

## Catatan Untuk Backend

- Semua endpoint complete sebaiknya idempotent, agar aman jika mobile retry.
- Backend sebaiknya mengembalikan `nextTask` setelah complete agar mobile tidak perlu hit endpoint tambahan.
- Jika tidak ada `nextTask`, backend mengembalikan `isStageCompleted: true`.
- Tracking number perlu persist di backend karena sekarang mobile belum punya endpoint untuk menyimpannya.
- `SalesOrderItemId` wajib dikirim ke mobile karena mobile akan mengirim status selesai per item.
- Untuk picking, backend perlu mengirim `shelfId` dan `shelfQrCode` atau `shelfCode` sebagai patokan validasi scan.
- Untuk packing, backend perlu mengirim `barcode` sebagai patokan validasi scan item.
