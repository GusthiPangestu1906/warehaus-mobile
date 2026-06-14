# Backend Contract: Print Label Sales Order

Dokumen ini menjelaskan endpoint backend yang dibutuhkan untuk fitur `Print Label Sales Order` pada flow Outbound.

Referensi UI:

- `Flow - Outbound - Detail SO 4.png`: detail Sales Order setelah selesai, status harus `Completed`.
- `A4 - Label SO (1).png`: hasil print label A4.

## Status Saat Ini Di Mobile

Berdasarkan kode mobile saat ini:

- Belum ada endpoint print label di `SalesOrderApiDatasource`.
- Belum ada endpoint complete packing / complete sales order di `SalesOrderApiDatasource`.
- Tombol `Complete & Print Label` di `packing_page.dart` hanya update status lokal melalui `UpdateSalesOrderLocalStatusEvent`.
- Karena status hanya lokal, status `Active -> Completed` belum persist ke backend dan bisa kembali berubah setelah refresh/load ulang data.

Endpoint yang sudah ada di mobile saat ini:

```text
GET    /api/outbound/sales-orders
GET    /api/outbound/sales-orders/{id}
POST   /api/outbound/sales-orders
DELETE /api/outbound/sales-orders/{id}
PATCH  /api/outbound/sales-orders/{id}/tracking
GET    /api/outbound/sales-orders/{id}/picking/next-task
POST   /api/outbound/sales-orders/{id}/picking/items/{salesOrderItemId}/complete
```

Endpoint print label dan final complete belum tersedia dari sisi mobile integration.

## Flow Yang Diharapkan

1. User menyelesaikan picking.
2. User masuk packing.
3. User scan/verifikasi semua item packing.
4. User menekan tombol `Complete & Print Label`.
5. Mobile memanggil endpoint backend untuk complete packing/finalize SO.
6. Backend mengubah status Sales Order menjadi `Completed`.
7. Backend mengembalikan data label.
8. Mobile menampilkan/mencetak label A4.
9. Detail SO menampilkan badge `Completed` dan tombol `Print Label Sales Order`.

## Endpoint 1: Complete Packing / Finalize Sales Order

Endpoint ini dipanggil setelah semua item packing verified.

```http
POST /api/outbound/sales-orders/{salesOrderId}/packing/complete
```

Request:

```json
{
  "verifiedItems": [
    {
      "salesOrderItemId": 55,
      "productId": 2,
      "packedQty": 230
    }
  ]
}
```

Response:

```json
{
  "salesOrderId": 10,
  "soNumber": "SO-040926-01",
  "status": "Completed",
  "isCompleted": true,
  "completedAt": "2026-05-28T00:00:00.000Z",
  "totalOrderedQuantity": 230,
  "totalPickedItems": 230,
  "totalVerifiedItems": 230,
  "progressPercentage": 100,
  "labelAvailable": true
}
```

Backend wajib persist status ini, supaya endpoint list/detail berikutnya juga mengembalikan status completed.

## Endpoint 2: Get Label Data

Endpoint ini mengembalikan data terstruktur untuk render label A4 seperti desain.

```http
GET /api/outbound/sales-orders/{salesOrderId}/label
```

Response:

```json
{
  "salesOrderId": 10,
  "createdAt": "2026-09-04T00:00:00.000Z",
  "printedAt": "2026-05-28T00:00:00.000Z",
  "soNumber": "SO-040926-01",
  "slaDate": "2026-10-10T00:00:00.000Z",
  "trackingNumber": "SPH38149634",
  "companyName": "PT. Material Indo",
  "customerName": "Joe Doe",
  "courierName": "Speed Haul",
  "address": "Jl. Raya ITS, Gedung D4, Keputih",
  "province": "East Java",
  "city": "Surabaya",
  "district": "Sukolilo",
  "postalCode": "36812",
  "note": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  "items": [
    {
      "no": 1,
      "salesOrderItemId": 55,
      "productId": 2,
      "sku": "TEA-GRN-90",
      "productName": "Green Tea 90g",
      "qty": 230,
      "unitOfMeasure": "Box"
    }
  ],
  "signatureLabel": "Supervisor"
}
```

## Endpoint 3: Print Label As PDF

Jika backend yang generate file PDF:

```http
GET /api/outbound/sales-orders/{salesOrderId}/label.pdf
```

Response:

```http
Content-Type: application/pdf
Content-Disposition: inline; filename="SO-040926-01-label.pdf"
```

Mobile bisa membuka/download PDF ini untuk dicetak.

## Endpoint 4: Mark Label Printed

Jika backend perlu mencatat bahwa label sudah dicetak:

```http
POST /api/outbound/sales-orders/{salesOrderId}/label/print
```

Request:

```json
{
  "printedAt": "2026-05-28T00:00:00.000Z"
}
```

Response:

```json
{
  "salesOrderId": 10,
  "labelPrinted": true,
  "labelPrintedAt": "2026-05-28T00:00:00.000Z"
}
```

Endpoint ini opsional jika status completed sudah cukup.

## Sales Order Detail Setelah Completed

Endpoint detail harus mengembalikan data lengkap untuk screen `DETAIL SO`.

```http
GET /api/outbound/sales-orders/{salesOrderId}
```

Response minimal setelah completed:

```json
{
  "id": 10,
  "soNumber": "SO-040926-01",
  "orderDate": "2026-09-04T00:00:00.000Z",
  "requiredDeliveryDate": "2026-10-10T00:00:00.000Z",
  "trackingNumber": "SPH38149634",
  "customerName": "Joe Doe",
  "companyName": "PT. Material Indo",
  "courierName": "Speed Haul",
  "shippingAddress": "Jl. Raya ITS, Gedung D4, Keputih, Sukolilo, Surabaya, East Java 36812",
  "provinceCode": "East Java",
  "cityCode": "Surabaya",
  "districtCode": "Sukolilo",
  "postalCode": "36812",
  "note": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  "status": "Completed",
  "isCompleted": true,
  "totalOrderedQuantity": 230,
  "totalPickedItems": 230,
  "totalVerifiedItems": 230,
  "progressPercentage": 100,
  "labelPrinted": true,
  "items": [
    {
      "salesOrderItemId": 55,
      "productId": 2,
      "sku": "TEA-GRN-90",
      "productName": "Green Tea 90g",
      "qtyOrdered": 230,
      "unitOfMeasure": "Box"
    }
  ]
}
```

## Status Mapping

Backend perlu memastikan mapping berikut:

| Kondisi | `status` | `isCompleted` | UI Mobile |
| --- | --- | --- | --- |
| Belum ada tracking number | `Queued` | `false` | Queued |
| Sudah ada tracking / picking / packing | `Picking` atau `Packing` | `false` | Active |
| Packing selesai dan label siap/tercetak | `Completed` | `true` | Completed |

## Validasi Backend

Saat menerima request complete packing:

- Pastikan semua item SO sudah dipick.
- Pastikan semua item packing sudah verified.
- Pastikan `trackingNumber` sudah ada.
- Set `status = Completed`.
- Set `isCompleted = true`.
- Set `progressPercentage = 100`.
- Simpan waktu selesai di `completedAt`.
- Jika label dicetak/digenerate, simpan `labelPrinted` dan `labelPrintedAt` bila diperlukan.

## Catatan Untuk Mobile

Setelah backend siap, mobile perlu ditambahkan:

- Method `completePacking` di `SalesOrderApiDatasource`.
- Method `getSalesOrderLabel` atau `getSalesOrderLabelPdf`.
- Tombol `Complete & Print Label` harus call backend, bukan hanya update local Bloc.
- Screen detail completed harus menampilkan tombol `Print Label Sales Order`, bukan tombol disabled `Completed`.
