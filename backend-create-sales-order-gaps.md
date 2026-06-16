# Backend Create Sales Order Gaps

Dokumen ini merangkum kebutuhan backend untuk fitur **Create Sales Order** mobile.

Tanggal pengecekan: 14 Juni 2026  
Base URL yang dicek: `https://phoniness-stubble-flypaper.ngrok-free.dev`

## Status Singkat

Dropdown pendukung create SO sudah tersedia:

- `GET /api/products` tersedia dan mengembalikan `id`, `sku`, `productName`, `barcode`, `unitOfMeasure`.
- `GET /api/couriers` tersedia dan mengembalikan `id`, `code`, `name`, `serviceType`.
- `GET /api/regions/province` tersedia dan mengembalikan `code`, `name`.

Masalah yang masih perlu backend benahi:  

- `POST /api/outbound/sales-orders` masih mengembalikan `409 Conflict`.
- Field `note` belum disimpan/dikembalikan di response SO.
- Response create belum mengembalikan data SO yang baru dibuat.

## Payload Yang Dikirim Mobile

Mobile mengirim payload create SO seperti berikut:

```json
{
  "customerName": "Joe Doe",
  "companyName": "PT. Material Indo",
  "contactPerson": "Joe Doe",
  "phoneNumber": "08123456789",
  "note": "Catatan sales order dari user",
  "shippingAddress": "Jl. Raya ITS, Gedung D4",
  "provinceCode": "35",
  "cityCode": "35.15",
  "districtCode": "35.15.10",
  "postalCode": "61261",
  "courierId": 1,
  "requiredDeliveryDate": "2026-06-15T00:00:00.000Z",
  "items": [
    {
      "productId": 2,
      "qtyOrdered": 1
    }
  ]
}
```

## Masalah 1: Create SO Return 409

Saat dites dengan payload valid, backend mengembalikan:

```json
{
  "title": "Conflict Detected",
  "status": 409,
  "detail": "No route matches the supplied values.",
  "errors": [
    "No route matches the supplied values."
  ]
}
```

Ini biasanya terjadi di ASP.NET ketika controller memakai `CreatedAtAction`, `CreatedAtRoute`, atau return `Location` header dengan nama action/route yang tidak cocok.

Yang diharapkan:

- Jika create berhasil, backend return `201 Created` atau `200 OK`.
- Jangan return `409` untuk create yang valid.
- Response mengembalikan minimal `id` dan `soNumber`, lebih baik full Sales Order DTO.

Contoh response yang diharapkan:

```json
{
  "id": 17,
  "soNumber": "SO-202606140001",
  "customerName": "Joe Doe",
  "companyName": "PT. Material Indo",
  "contactPerson": "Joe Doe",
  "phoneNumber": "08123456789",
  "note": "Catatan sales order dari user",
  "shippingAddress": "Jl. Raya ITS, Gedung D4",
  "provinceCode": "35",
  "provinceName": "Jawa Timur",
  "cityCode": "35.15",
  "cityName": "Kabupaten Sidoarjo",
  "districtCode": "35.15.10",
  "districtName": "Wonoayu",
  "postalCode": "61261",
  "courierId": 1,
  "courierCode": "JNE_CARGO",
  "courierName": "JNE Cargo",
  "trackingNumber": null,
  "status": "Queued",
  "orderDate": "2026-06-14T00:00:00Z",
  "requiredDeliveryDate": "2026-06-15T00:00:00Z",
  "totalItems": 1,
  "totalOrderedQuantity": 1,
  "totalPickedItems": 0,
  "totalVerifiedItems": 0,
  "progressPercentage": 0,
  "isCompleted": false,
  "items": [
    {
      "id": 1,
      "productId": 2,
      "sku": "PRFM-MLK",
      "productName": "Parfum Malika",
      "barcode": "989738782",
      "unitOfMeasure": "PCS",
      "qtyOrdered": 1,
      "qtyPicked": 0,
      "qtyVerified": 0
    }
  ]
}
```

## Masalah 2: Field Note Belum Persist/Return

Response dari:

- `GET /api/outbound/sales-orders`
- `GET /api/outbound/sales-orders/{id}`

belum memiliki field:

```json
"note": "..."
```

Mobile sudah mengirim `note`, dan parser mobile juga sudah siap membaca:

- `note`
- `notes`
- `remarks`

Namun kontrak yang disarankan adalah gunakan satu nama field konsisten:

```json
"note": "Catatan sales order dari user"
```

Yang perlu backend tambahkan:

- Field `Note` di entity/database Sales Order.
- Field `note` di Create Sales Order request DTO.
- Field `note` di Update Sales Order request DTO.
- Mapping save `note` saat create/update.
- Field `note` di response list dan detail SO.

## Checklist Backend Create SO

- [ ] `POST /api/outbound/sales-orders` menerima payload mobile di atas.
- [ ] Create valid tidak return `409 No route matches the supplied values`.
- [ ] Create valid return `201 Created` atau `200 OK`.
- [ ] Response create mengembalikan data SO yang baru dibuat.
- [ ] Backend menyimpan `note`.
- [ ] `GET /api/outbound/sales-orders` mengembalikan `note`.
- [ ] `GET /api/outbound/sales-orders/{id}` mengembalikan `note`.
- [ ] `status` default SO baru adalah `Queued`.
- [ ] `items` response punya `id`, `productId`, `sku`, `productName`, `unitOfMeasure`, `qtyOrdered`, `qtyPicked`, dan `qtyVerified`.

## Dampak Ke Mobile

Saat backend sudah membenahi poin di atas, mobile tidak perlu fallback dummy untuk note.

Mobile saat ini sudah mengirim field:

```json
"note": "..."
```

dan sudah menampilkan `order.note` di Detail SO.
