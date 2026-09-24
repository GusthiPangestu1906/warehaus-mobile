import 'package:auth/domain/entities/app_permissions.dart';
import 'package:auth/domain/entities/user_session.dart';
import 'package:auth/presentation/bloc/auth_bloc.dart';
import 'package:auth/presentation/bloc/auth_state.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/presentation/bloc/navigation_bloc.dart';
import 'package:mobile/presentation/bloc/navigation_state.dart';
import 'package:mobile/route_observer.dart';
import 'package:product/domain/entities/product.dart';
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

  // Cache data produk terakhir yang berhasil dimuat agar UI tidak blank atau flickering
  List<Product> _lastKnownProducts = [];

  int _getProductTabIndex(UserSession? session) {
    if (session == null) return 1;
    int index = 0;
    if (session.hasPermission(AppPermissions.dashboardView)) {
      index++;
    }
    return index;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ProductBloc>().add(GetProductsEvent());
      }
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
    final authState = context.read<AuthBloc>().state;
    final session =
        authState is AuthenticatedState ? authState.session : null;
    final productTabIndex = _getProductTabIndex(session);
    final navigationState = context.read<NavigationBloc>().state;
    if (navigationState.currentIndex == productTabIndex) {
      context.read<ProductBloc>().add(GetProductsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Baca session dari AuthBloc untuk permission check
    final authState = context.read<AuthBloc>().state;
    final session =
        authState is AuthenticatedState ? authState.session : null;

    final canCreate = session?.hasPermission(AppPermissions.productCreate) ?? false;
    final canEdit = session?.hasPermission(AppPermissions.productEdit) ?? false;
    final canDelete = session?.hasPermission(AppPermissions.productDelete) ?? false;

    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (previous, current) =>
          previous.currentIndex != current.currentIndex,
      listener: (context, state) {
        final productTabIndex = _getProductTabIndex(session);
        if (state.currentIndex == productTabIndex) {
          context.read<ProductBloc>().add(GetProductsEvent());
        }
      },
      child: BlocListener<ProductBloc, ProductState>(
        listenWhen: (previous, current) => current is ProductError,
        listener: (context, state) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            if (state is ProductError) {
              WHSnackBar.showError(context, state.message);
            }
          }
        },
        child: Scaffold(
          backgroundColor: WHColors.background,
          appBar: WHAppbar(title: 'Product Management'),
          body: BlocBuilder<ProductBloc, ProductState>(
            buildWhen: (previous, current) =>
                current is ProductLoading ||
                current is ProductLoaded ||
                current is ProductError ||
                current is ProductInitial,
            builder: (context, state) {
              if (state is ProductLoaded) {
                _lastKnownProducts = state.products;
              }

              final bool isLoadingOverlay =
                  state is ProductLoading && _lastKnownProducts.isNotEmpty;
              final List<Product> productsToRender =
                  state is ProductLoaded ? state.products : _lastKnownProducts;

              Widget buildContent() {
                if (state is ProductLoading && _lastKnownProducts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductError && _lastKnownProducts.isEmpty) {
                  return WHRefresh(
                    onRefresh: () async {
                      context.read<ProductBloc>().add(GetProductsEvent());
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.message,
                                  style: WHTypography.bodyText,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context
                                        .read<ProductBloc>()
                                        .add(GetProductsEvent());
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: WHColors.primary3,
                                    foregroundColor: WHColors.surface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (_lastKnownProducts.isEmpty &&
                    state is! ProductLoading &&
                    state is! ProductLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      context.read<ProductBloc>().add(GetProductsEvent());
                    }
                  });
                  return const Center(child: CircularProgressIndicator());
                }

                if (productsToRender.isEmpty) {
                  return WHRefresh(
                    onRefresh: () async {
                      context.read<ProductBloc>().add(GetProductsEvent());
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: const WHEmptyState(
                          message:
                              "No products available.\nTap + to add a new product.",
                        ),
                      ),
                    ),
                  );
                }

                final query = _searchQuery.trim().toLowerCase();
                final filteredProducts = query.isEmpty
                    ? productsToRender
                    : productsToRender
                        .where(
                          (product) =>
                              product.productName.toLowerCase().contains(
                                query,
                              ) ||
                              product.sku.toLowerCase().contains(query) ||
                              product.barcode.toLowerCase().contains(query),
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
                    context.read<ProductBloc>().add(GetProductsEvent());
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    itemBuilder: (itemCtx, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onView: () async {
                          final bloc = context.read<ProductBloc>();
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
                          bloc.add(GetProductsEvent());
                        },
                      );
                    },
                  ),
                );
              }

              return Column(
                children: [
                  if (isLoadingOverlay)
                    LinearProgressIndicator(
                      color: WHColors.primary3,
                      backgroundColor: WHColors.primary3.withValues(alpha: 0.15),
                      minHeight: 3,
                    ),
                  Expanded(
                    child: Container(
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
                          Expanded(child: buildContent()),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: canCreate
              ? FloatingActionButton(
                  heroTag: 'product-create-fab',
                  onPressed: () async {
                    final bloc = context.read<ProductBloc>();
                    await Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, _, _) => const CreateProductPage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                    if (!mounted) return;
                    bloc.add(GetProductsEvent());
                  },
                  backgroundColor: WHColors.primary3,
                  child: const Icon(Icons.add, color: WHColors.surface),
                )
              : null,
        ),
      ),
    );
  }
}
