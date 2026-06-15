# Backend Gaps: Outbound Active To Completed

Dokumen ini merangkum kekurangan backend yang masih menghambat flow Outbound di mobile, terutama perubahan status `Active` menjadi `Completed` dan fitur print label.

Tanggal cek terakhir: 14/06/2026

Base URL yang dicek dari `.env`:

```text
https://phoniness-stubble-flypaper.ngrok-free.dev
```

## Kondisi Backend Saat Ini

Endpoint yang sudah tersedia dan berhasil dicek:

```http
GET /api/outbound/sales-orders
GET /api/outbound/sales-orders/{id}
GET /api/products
GET /api/couriers
GET /api/regions/province
GET /api/outbound/sales-orders/{id}/label
```

Endpoint label sudah ada, tetapi hanya bisa diakses jika Sales Order sudah `Completed`.

Contoh response saat SO belum completed:

```json
{
  "status": 409,
  "detail": "Label hanya tersedia setelah Sales Order berstatus Completed.",
  "errors": [
    "Label hanya tersedia setelah Sales Order berstatus Completed."
  ]
}
```

Response Sales Order terbaru sudah mengirim field yang bagus untuk mobile:

```json
{
  "provinceName": "Jawa Barat",
  "cityName": "Kabupaten Karawang",
  "districtName": "Klari",
  "courierCode": "SICEPAT_CARGO",
  "courierName": "SiCepat Cargo",
  "items": [
    {
      "formattedQuantity": "Qty: 1 PCS",
      "suggestedLocations": []
    }
  ]
}
```

## Masalah Utama

Saat ini mobile belum bisa benar-benar mengubah status dari `Active` menjadi `Completed` di backend.

Di mobile, tombol `Complete & Print Label` pada halaman packing baru mengubah status lokal saja:

```text
UpdateSalesOrderLocalStatusEvent(status: "Completed")
```

Akibatnya:

- Status terlihat `Completed` sementara di state Flutter.
- Setelah refresh/load ulang data, status kembali mengikuti backend.
- Endpoint label tetap menolak dengan `409` karena backend belum menganggap SO completed.

## Bug Create Sales Order Saat Ini

Saat mobile submit form SO, backend terkadang mengembalikan:

```text
409 Conflict
No route matches the supplied values.
```

Namun dari hasil cek `GET /api/outbound/sales-orders`, data Sales Order tetap berhasil dibuat. Ini berarti proses insert kemungkinan sukses, tetapi backend gagal membuat response setelah create.

Kemungkinan penyebab di ASP.NET:

- `CreatedAtAction(...)` memakai action name atau route value yang tidak cocok.
- `CreatedAtRoute(...)` memakai route name yang tidak terdaftar.
- Response create mencoba membuat URL detail dengan parameter yang salah.

Contoh perbaikan backend:

```csharp
return CreatedAtAction(
    nameof(GetSalesOrderById),
    new { id = createdSalesOrder.Id },
    responseDto
);
```

Atau jika route detail belum stabil, sementara bisa memakai:

```csharp
return Ok(responseDto);
```

Acceptance criteria:

- `POST /api/outbound/sales-orders` harus return `200 OK` atau `201 Created`.
- Jangan return `409` jika data berhasil dibuat.
- Response create minimal mengembalikan `id`, `soNumber`, `status`, dan `items`.
- Jika benar-benar terjadi conflict valid, misalnya duplicate business key, barulah return `409` dengan pesan conflict yang jelas.

Catatan mobile:

- Mobile sudah menambahkan guard sementara: `409` dengan pesan `No route matches the supplied values` dianggap sukses agar user tidak submit berulang.
- Guard ini hanya workaround. Backend tetap perlu mengembalikan status code sukses.

## Endpoint Yang Masih Dibutuhkan

### 0. Detail SO Completed Dari Card List

Saat user menekan card Sales Order dengan status `Completed` di list Outbound, mobile akan membuka screen `DETAIL SO` seperti desain Figma:

```text
DETAIL SO
Created at 04/09/2026
SO-040926-01
Completed

SLA 10/10/2026
Tracking Number SPH38149634
Customer + Company
Courier
Address
Province / City / Postal Code
Note
Print Label Sales Order
Product List
```

Supaya screen ini tidak perlu menebak/fallback, backend perlu memastikan endpoint detail mengembalikan data lengkap.

Endpoint utama:

```http
GET /api/outbound/sales-orders/{salesOrderId}
```

Response minimal untuk SO completed:

```json
{
  "id": 10,
  "soNumber": "SO-040926-01",
  "orderDate": "2026-09-04T00:00:00Z",
  "requiredDeliveryDate": "2026-10-10T00:00:00Z",
  "trackingNumber": "SPH38149634",
  "status": "Completed",
  "isCompleted": true,
  "customerName": "Joe Doe",
  "companyName": "PT. Material Indo",
  "contactPerson": "Joe Doe",
  "phoneNumber": "08123456789",
  "courierId": 1,
  "courierCode": "SPEED_HAUL",
  "courierName": "Speed Haul",
  "shippingAddress": "Jl. Raya ITS, Gedung D4, Keputih, Sukolilo, Surabaya, East Java 36812",
  "provinceCode": "35",
  "provinceName": "East Java",
  "cityCode": "35.78",
  "cityName": "Surabaya",
  "districtCode": "35.78.01",
  "districtName": "Sukolilo",
  "postalCode": "36812",
  "note": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  "totalItems": 3,
  "totalOrderedQuantity": 690,
  "totalPickedItems": 690,
  "totalVerifiedItems": 690,
  "progressPercentage": 100,
  "labelAvailable": true,
  "labelPrinted": false,
  "completedAt": "2026-06-14T00:00:00Z",
  "items": [
    {
      "id": 55,
      "salesOrderItemId": 55,
      "productId": 2,
      "sku": "TEA-GRN-90",
      "productName": "Green Tea 90g",
      "barcode": "899000000001",
      "qtyOrdered": 230,
      "qtyPicked": 230,
      "qtyVerified": 230,
      "unitOfMeasure": "Box",
      "formattedQuantity": "Qty: 230 Box"
    }
  ]
}
```

Field yang penting untuk screen completed:

| Area UI | Field backend |
| --- | --- |
| Header tanggal | `orderDate` atau `createdAt` |
| Nomor SO | `soNumber` |
| Badge completed | `status: "Completed"` dan `isCompleted: true` |
| SLA | `requiredDeliveryDate` |
| Tracking | `trackingNumber` |
| Customer | `customerName` / `contactPerson` |
| Company | `companyName` |
| Courier | `courierName` |
| Address | `shippingAddress` |
| Region pills | `provinceName`, `cityName`, `postalCode` |
| Note card | `note` |
| Print label button | `labelAvailable: true` atau endpoint `/label` return `200` |
| Product list | `items[].sku`, `items[].productName`, `items[].qtyOrdered`, `items[].unitOfMeasure` |

Catatan penting:

- Saat ini backend response yang dicek sudah memiliki `provinceName`, `cityName`, `districtName`, `courierName`, dan item product.
- Field `note` belum terlihat pada response yang dicek. Untuk desain completed, backend perlu mengirim `note`, walaupun nilainya kosong.
- Untuk product list, backend perlu mengirim `sku` asli. Jangan hanya `productId`, karena UI desain menampilkan SKU seperti `TEA-GRN-90`.
- Jika `cityName` mengandung prefix `Kabupaten` atau `Kota`, mobile bisa membersihkan tampilan. Tetapi lebih ideal backend tetap konsisten mengirim nama resmi.

Rekomendasi mobile/backend:

- Backend tetap wajib menyediakan detail lengkap di `GET /api/outbound/sales-orders/{id}`.
- Mobile idealnya fetch ulang endpoint detail saat card list ditekan, terutama untuk SO completed, agar data detail tidak basi dari list.
- Jika mobile tidak fetch ulang detail, maka `GET /api/outbound/sales-orders` juga harus mengirim field yang sama lengkapnya.

### 1. Complete Packing / Finalize Sales Order

Endpoint ini wajib ada agar mobile bisa persist status `Completed` ke backend.

Rekomendasi:

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
      "packedQty": 1
    }
  ]
}
```

Response sukses:

```json
{
  "salesOrderId": 5,
  "soNumber": "SO-20260613123158919",
  "status": "Completed",
  "isCompleted": true,
  "completedAt": "2026-06-14T00:00:00Z",
  "totalOrderedQuantity": 1,
  "totalPickedItems": 1,
  "totalVerifiedItems": 1,
  "progressPercentage": 100,
  "labelAvailable": true
}
```

Setelah endpoint ini sukses, endpoint berikut harus ikut mengembalikan status completed:

```http
GET /api/outbound/sales-orders
GET /api/outbound/sales-orders/{id}
```

Minimal field:

```json
{
  "status": "Completed",
  "isCompleted": true,
  "progressPercentage": 100
}
```

### 2. Packing Task / Verify Item

Jika backend ingin packing diverifikasi per item, mobile butuh endpoint task/verify packing.

Opsi endpoint:

```http
GET /api/outbound/sales-orders/{salesOrderId}/packing/tasks
POST /api/outbound/sales-orders/{salesOrderId}/packing/items/{salesOrderItemId}/verify
```

Response verify:

```json
{
  "salesOrderId": 5,
  "salesOrderItemId": 5,
  "productId": 2,
  "sku": "PRFM-MLK",
  "productName": "Parfum Malika",
  "verifiedQty": 1,
  "unitOfMeasure": "PCS",
  "isVerified": true,
  "progress": {
    "completedItems": 1,
    "totalItems": 1,
    "completedQuantity": 1,
    "totalQuantity": 1
  }
}
```

Kalau backend tidak butuh verify per item, endpoint ini opsional. Tetapi `packing/complete` tetap wajib.

### 3. Label Data Setelah Completed

Endpoint ini sudah ada:

```http
GET /api/outbound/sales-orders/{salesOrderId}/label
```

Yang masih perlu dipastikan:

- Mengembalikan `200` setelah SO completed.
- Mengembalikan data lengkap untuk render label A4.
- Tidak hanya mengembalikan PDF jika mobile akan render label sendiri.

Response yang dibutuhkan mobile:

```json
{
  "salesOrderId": 5,
  "createdAt": "2026-06-13T12:31:58.976484Z",
  "printedAt": "2026-06-14T00:00:00Z",
  "soNumber": "SO-20260613123158919",
  "slaDate": "2026-06-14T00:00:00Z",
  "trackingNumber": "SPH38149634",
  "companyName": "bhy",
  "customerName": "ffff",
  "courierName": "SiCepat Cargo",
  "address": "ftttf",
  "province": "Jawa Barat",
  "city": "Karawang",
  "district": "Klari",
  "postalCode": "5552",
  "note": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
  "items": [
    {
      "no": 1,
      "salesOrderItemId": 5,
      "productId": 2,
      "sku": "PRFM-MLK",
      "productName": "Parfum Malika",
      "qty": 1,
      "unitOfMeasure": "PCS"
    }
  ],
  "signatureLabel": "Supervisor"
}
```

Acceptance criteria untuk output A4 sesuai desain:

| Area Label A4 | Data yang wajib tersedia |
| --- | --- |
| Header kiri | `createdAt`/`orderDate`, `soNumber` |
| Header tengah | `slaDate`/`requiredDeliveryDate` |
| Header kanan | `trackingNumber` |
| Info kiri | `companyName`, `customerName`, `courierName` |
| Info tengah | `address`, `province`, `city`, `district`, `postalCode` |
| Info kanan | `note` |
| Tabel produk | `no`, `sku`, `productName`, `qty`, `unitOfMeasure` |
| Footer tanggal print | `printedAt` dalam format tanggal lokal |
| Signature | `signatureLabel`, default `Supervisor` |

Backend dinyatakan siap untuk print label jika:

- `GET /api/outbound/sales-orders/{id}/label` return `200` untuk SO completed.
- Response berisi semua field di atas.
- Jika backend mengembalikan PDF, ukuran layout harus A4 portrait.
- Jika backend mengembalikan JSON, mobile akan render layout A4 dari field tersebut.
- `qty` dan `unitOfMeasure` harus terpisah atau minimal bisa dibentuk menjadi teks seperti `230 Box`.
- `items` harus mempertahankan urutan produk yang sama dengan Sales Order.
- `note` tetap dikirim walaupun kosong, agar layout tidak perlu fallback hardcoded.

### 4. Label PDF Opsional

Jika backend yang generate PDF:

```http
GET /api/outbound/sales-orders/{salesOrderId}/label.pdf
```

Response:

```http
Content-Type: application/pdf
Content-Disposition: inline; filename="SO-20260613123158919-label.pdf"
```

Endpoint ini opsional jika mobile akan render PDF/print layout sendiri.

## Validasi Backend Yang Diperlukan

Saat `packing/complete` dipanggil, backend perlu memastikan:

- Sales Order sudah punya `trackingNumber`.
- Sales Order sudah melewati picking.
- Semua quantity yang dipick sesuai quantity order.
- Semua item packing sudah verified, jika backend menerapkan verify packing.
- Setelah valid, set:

```text
status = Completed
isCompleted = true
progressPercentage = 100
completedAt = waktu sekarang
totalVerifiedItems = totalOrderedQuantity
```

## Status Mapping Yang Diharapkan Mobile

| Kondisi | status | isCompleted | Tampilan Mobile |
| --- | --- | --- | --- |
| Belum ada tracking number | Queued | false | Queued |
| Sudah ada tracking number | Active | false | Active |
| Picking selesai, masuk packing | Packing atau Active | false | Active / Packing flow |
| Packing selesai | Completed | true | Completed |

Mobile saat ini sudah menganggap order completed jika:

```text
isCompleted == true
status == "Completed" / "Complete" / "Done" / "Closed"
```

## Catatan Warning EF Core

Backend saat ini juga mengeluarkan warning:

```text
Compiling a query which loads related collections for more than one collection navigation...
```

Ini bukan penyebab error mobile, tetapi sebaiknya backend membenahi query dengan salah satu cara:

```csharp
.AsSplitQuery()
```

atau konfigurasi global:

```csharp
options.UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery);
```

Warning ini muncul karena query memakai beberapa `Include` collection sekaligus. Jika dibiarkan, performa query Sales Order bisa lambat saat data membesar.

## Checklist Backend

- [ ] Pastikan `GET /api/outbound/sales-orders/{id}` punya data lengkap untuk screen Detail SO Completed.
- [ ] Tambahkan field `note` di response SO detail/list.
- [ ] Tambahkan `labelAvailable`, `labelPrinted`, dan `completedAt` di response SO completed.
- [ ] Pastikan item SO mengirim `sku`, `productName`, `qtyOrdered`, dan `unitOfMeasure`.
- [ ] Tambahkan endpoint `POST /api/outbound/sales-orders/{id}/packing/complete`.
- [ ] Persist status SO menjadi `Completed`.
- [ ] Pastikan `GET /api/outbound/sales-orders` mengembalikan `status: Completed`.
- [ ] Pastikan `GET /api/outbound/sales-orders/{id}` mengembalikan `isCompleted: true`.
- [ ] Pastikan `GET /api/outbound/sales-orders/{id}/label` return `200` setelah completed.
- [ ] Pastikan label response punya data lengkap untuk A4.
- [ ] Opsional: tambahkan endpoint packing task/verify per item.
- [ ] Opsional: tambahkan endpoint label PDF.
- [ ] Benahi warning EF Core multiple collection include.

## Dampak Ke Mobile Setelah Backend Siap

Setelah endpoint backend tersedia, mobile perlu ditambahkan:

- Method `completePacking` di `SalesOrderApiDatasource`.
- Event/usecase repository untuk complete packing.
- Tombol `Complete & Print Label` memanggil backend, bukan local status.
- Setelah complete sukses, mobile fetch label dari endpoint `/label`.
- Detail SO completed menampilkan tombol `Print Label Sales Order`.
