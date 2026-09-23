import 'package:auth/domain/entities/app_permissions.dart';
import 'package:auth/presentation/bloc/auth_bloc.dart';
import 'package:auth/presentation/bloc/auth_state.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/presentation/bloc/navigation_bloc.dart';
import 'package:mobile/route_observer.dart';
import 'package:product/presentation/bloc/product_bloc.dart';
import 'package:product/presentation/bloc/product_event.dart';
import 'package:product/presentation/bloc/product_state.dart';
import 'package:product/presentation/pages/create_product_page.dart';
import 'package:product/presentation/pages/product_detail_page.dart';
import 'package:product/presentation/widgets/product_card.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductBloc>().add(GetProductsEvent());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Only fetch if this page is currently displayed (tab index 1)
    final navigationState = context.read<NavigationBloc>().state;
    if (navigationState.currentIndex == 1) {
      context.read<ProductBloc>().add(GetProductsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Baca session dari AuthBloc untuk permission check
    final AuthState = context.read<AuthBloc>().state;
    final session =
        AuthState is AuthenticatedState ? AuthState.session : null;

    final canCreate = session?.hasPermission(AppPermissions.productCreate) ?? false;
    final canEdit = session?.hasPermission(AppPermissions.productEdit) ?? false;
    final canDelete = session?.hasPermission(AppPermissions.productDelete) ?? false;

    return Scaffold(
      backgroundColor: WHColors.background,
      appBar: WHAppbar(title: 'Product Management'),
      body: Container(
        color: WHColors.background,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            WHSearch(
              hintText: 'Search products',
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ProductDetailLoaded ||
                      state is ProductInitial ||
                      state is ProductActionSuccess) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ProductError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: WHTypography.bodyText,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  if (state is ProductLoaded) {
                    if (state.products.isEmpty) {
                      // 1. Bungkus Empty State agar tetap bisa ditarik (pull-to-refresh)
                      return WHRefresh(
                        onRefresh: () async {
                          context.read<ProductBloc>().add(GetProductsEvent());
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            // Memastikan EmptyState berada di tengah layar
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const WHEmptyState(
                              message:
                                  "No products available.\nTap + to add a new product.",
                            ),
                          ),
                        ),
                      );
                    }

                    // 2. Bungkus ListView.builder dengan WHRefresh
                    final query = _searchQuery.trim().toLowerCase();
                    final filteredProducts = query.isEmpty
                        ? state.products
                        : state.products
                              .where(
                                (product) =>
                                    product.productName.toLowerCase().contains(
                                      query,
                                    ) ||
                                    product.sku.toLowerCase().contains(query),
                              )
                              .toList();

                    if (filteredProducts.isEmpty) {
                      return WHRefresh(
                        onRefresh: () async {
                          context.read<ProductBloc>().add(GetProductsEvent());
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const WHEmptyState(
                              message: 'No products match your search.',
                            ),
                          ),
                        ),
                      );
                    }

                    return WHRefresh(
                      onRefresh: () async {
                        // Trigger event bloc untuk mengambil data ulang
                        context.read<ProductBloc>().add(GetProductsEvent());
                      },
                      child: ListView.builder(
                        // Tambahkan physics ini agar list selalu bisa ditarik meskipun itemnya sedikit
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return ProductCard(
                            product: product,
                            onView: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailPage(
                                    productId: product.id,
                                    canEdit: canEdit,
                                    canDelete: canDelete,
                                  ),
                                ),
                              );
                              if (!mounted) return;
                              context.read<ProductBloc>().add(
                                GetProductsEvent(),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              heroTag: 'product-create-fab',
              onPressed: () async {
                await Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => const CreateProductPage(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
                // NOTE: GetProductsEvent is already handled by two places:
                // 1. ProductBloc fires it internally after CreateProductEvent succeeds.
                // 2. didPopNext() fires it when this page comes back to the top.
                // No need to fire it a third time here.
              },
              backgroundColor: WHColors.primary3,
              child: const Icon(Icons.add, color: WHColors.surface),
            )
          : null,
    );
  }
}
