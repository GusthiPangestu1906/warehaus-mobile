import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product/domain/entities/stock.dart';
import 'package:product/presentation/bloc/product_bloc.dart';
import 'package:product/presentation/bloc/product_event.dart';
import 'package:product/presentation/bloc/product_state.dart';
import 'package:product/presentation/pages/edit_product_page.dart';
import 'package:product/presentation/widgets/move_stock_dialog.dart';
import 'package:product/presentation/widgets/stock_edit_dialog.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductBloc>().add(GetProductDetailsEvent(widget.productId));
    });
  }

  int _totalStock(ProductDetailLoaded state) {
    final stocks = state.product.stocks;
    if (stocks == null || stocks.isEmpty) return 0;
    return stocks.fold<int>(0, (sum, stock) => sum + stock.quantity);
  }

  Future<void> _confirmDeleteProduct(String productId, String sku) async {
    final confirmed = await WHDeleteDialog.show(
      context: context,
      title: 'Are you sure you want to delete this product?',
      identifier: sku,
      barrierDismissible: false,
    );

    if (!mounted || confirmed != true) return;

    context.read<ProductBloc>().add(DeleteProductEvent(productId));
  }

  Future<void> _confirmDeleteStockLocation({
    required String productId,
    required int shelfId,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Shelf Location'),
        content: const Text('Delete this shelf location from the product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: WHColors.error2),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      // Reload product details after delete
      context.read<ProductBloc>().add(GetProductDetailsEvent(productId));
    }
  }

  Future<void> _openEditProductPage(ProductDetailLoaded state) async {
    final product = state.product;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProductPage(
          productId: widget.productId,
          initialSku: product.sku,
          initialProductName: product.productName,
          initialBarcode: product.barcode,
          initialUnitOfMeasure: product.unitOfMeasure,
          initialCategoryId: product.categoryId,
        ),
      ),
    );
    // No manual refresh needed here: ProductBloc already re-dispatches
    // GetProductDetailsEvent internally right after a successful update,
    // so this BlocBuilder will pick up the latest ProductDetailLoaded state
    // automatically once we're back on this page.
  }

  Widget _buildShelfStockCard(
    Stock stock,
    String unitOfMeasure, {
    required String productId,
  }) {
    final title = (stock.shelfCode?.isNotEmpty ?? false)
        ? stock.shelfCode!
        : (stock.locationName?.isNotEmpty ?? false)
        ? stock.locationName!
        : 'Unknown shelf';
    final uomLabel = unitOfMeasure.isNotEmpty ? unitOfMeasure : 'Pcs';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: WHColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WHColors.grey5),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        iconColor: WHColors.grey3,
        collapsedIconColor: WHColors.grey3,
        title: Text(
          title,
          style: WHTypography.bodyText.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${stock.quantity} $uomLabel',
          style: WHTypography.bodyText.copyWith(color: WHColors.grey2),
        ),
        children: [
          Row(
            children: [
              SizedBox(
                width: 44,
                height: 36,
                child: OutlinedButton(
                  onPressed: () => _confirmDeleteStockLocation(
                    productId: productId,
                    shelfId: stock.shelfId,
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: WHColors.error3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: WHColors.error2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await showStockEditDialog(
                      context,
                      initialQuantity: stock.quantity,
                      shelfCode: stock.shelfCode ?? 'Unknown',
                    );

                    if (result != null && mounted) {
                      context.read<ProductBloc>().add(
                        UpdateStockLocationEvent(
                          productId: productId,
                          shelfId: stock.shelfId,
                          quantity: result.quantity,
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: WHColors.primary3,
                  ),
                  label: Text(
                    'Stock',
                    style: WHTypography.bodyText.copyWith(
                      color: WHColors.primary3,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: WHColors.primary4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await showMoveStockDialog(
                      context,
                      fromShelfId: stock.shelfId,
                      fromShelfCode: stock.shelfCode ?? 'Unknown',
                      currentQuantity: stock.quantity,
                      productId: productId,
                    );

                    if (result != null && mounted) {
                      // Move handled in dialog via QR scanner + bloc
                    }
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: WHColors.primary3,
                  ),
                  label: Text(
                    'Location',
                    style: WHTypography.bodyText.copyWith(
                      color: WHColors.primary3,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: WHColors.primary4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductActionSuccess && state.action == 'deleted') {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: WHColors.background,
        appBar: WHAppbar(title: 'Detail Product'),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductLoaded || state is ProductInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProductError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    state.message,
                    style: WHTypography.bodyText,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is ProductDetailLoaded) {
              final product = state.product;
              final stocks = product.stocks ?? const [];

              return WHRefresh(
                onRefresh: () async {
                  context.read<ProductBloc>().add(
                    GetProductDetailsEvent(widget.productId),
                  );
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: WHColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: WHColors.grey5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: WHTypography.heading1.copyWith(
                                color: WHColors.primary1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: WHColors.grey5),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'SKU',
                                      style: WHTypography.caption,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: WHColors.grey4,
                                        ),
                                      ),
                                      child: Text(
                                        product.sku,
                                        style: WHTypography.bodyText,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Current Stock',
                                      style: WHTypography.caption,
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${_totalStock(state)} ',
                                            style: WHTypography.heading1
                                                .copyWith(
                                                  color: WHColors.secondary4,
                                                ),
                                          ),
                                          TextSpan(
                                            text: product.unitOfMeasure,
                                            style: WHTypography.bodyText
                                                .copyWith(
                                                  color: WHColors.secondary4,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _openEditProductPage(state),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 16,
                                      color: WHColors.primary3,
                                    ),
                                    label: Text(
                                      'Edit',
                                      style: WHTypography.bodyText.copyWith(
                                        color: WHColors.primary3,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: WHColors.primary4,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _confirmDeleteProduct(
                                      widget.productId,
                                      product.sku,
                                    ),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: WHColors.error2,
                                    ),
                                    label: Text(
                                      'Delete',
                                      style: WHTypography.bodyText.copyWith(
                                        color: WHColors.error2,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: WHColors.error3,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Shelf Location and Stock',
                        style: WHTypography.heading2.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (stocks.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: WHColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: WHColors.grey5),
                          ),
                          child: Text(
                            'No shelf data available',
                            style: WHTypography.bodyText.copyWith(
                              color: WHColors.grey2,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: stocks
                              .map(
                                (stock) => _buildShelfStockCard(
                                  stock,
                                  product.unitOfMeasure,
                                  productId: widget.productId,
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
