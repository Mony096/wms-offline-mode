import 'package:flutter/material.dart';
import 'package:wms_mobile/constant/style.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic item;
  const ProductDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: PRIMARY_COLOR,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          title: const Text(
            "Item Master",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            )
          ],
          bottom: TabBar(
            isScrollable: true,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF131A3F), // Dark navy blue
            ),
            indicatorPadding: const EdgeInsets.symmetric(horizontal: -10, vertical: 8),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black87,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: [
              Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100, // Background when unselected
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Text("General")),
                ),
              ),
              Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Text("Purchasing")),
                ),
              ),
              Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Text("Sales")),
                ),
              ),
              Tab(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(child: Text("Inventory")),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildGeneralTab(item),
                  _buildPurchasingTab(item),
                  _buildSalesTab(item),
                  _buildInventoryTab(item),
                ],
              ),
            ),
            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle Save
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF131A3F), // Dark Navy
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, {bool isDropdown = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (isDropdown)
                const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralTab(dynamic item) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Image Carousel Mock
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(Icons.computer, size: 80, color: Colors.grey.shade300),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('1/3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined, size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Item Details
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['ItemName'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Code: ${item['ItemCode'] ?? ''}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Active',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Item group', 'Laptops', isDropdown: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Item type', 'Inventory', isDropdown: true)),
          ],
        ),
        const SizedBox(height: 16),
        // Barcode Table
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: const [
                    Expanded(flex: 1, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(flex: 2, child: Text('UoM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(flex: 4, child: Text('Barcode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    SizedBox(width: 24), // For action icon
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildBarcodeRow('1', 'Pcs', '7861234509981'),
              const Divider(height: 1),
              _buildBarcodeRow('2', 'Cartoon', '7961234509989'),
              const Divider(height: 1),
              _buildBarcodeRow('3', 'Pack', '7871234509998'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField('Remark', 'Monitor Dell 27" E2723H - FHD (1920 x 1080) 60Hz\n(Port: DP, VGA) (DP Cable) - 3Y'),
      ],
    );
  }

  Widget _buildBarcodeRow(String no, String uom, String barcode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(no, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 2, child: Text(uom, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 4, child: Text(barcode, style: const TextStyle(fontSize: 13))),
          const Icon(Icons.file_copy_outlined, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildPurchasingTab(dynamic item) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField('Purchasing UoM', 'Carton')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Items/purch. unit', '10')),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Preferred vendor', 'V-00214 Acme Distribution'),
        const SizedBox(height: 16),
        _buildTextField('Vendor catalog no', 'ACM-LT17-BLK'),
        const SizedBox(height: 16),
        _buildTextField('HS Code', '8528.52.00'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Country of origin', 'Vietnam')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Lead time', '7 Days')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Min. order qty', '50 Units')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Tax category', 'VAT10')),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Last purchase price', '\$ 890.00'),
      ],
    );
  }

  Widget _buildSalesTab(dynamic item) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField('Sales UoM', 'Unit')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Items/sales unit', '1')),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Tax category', 'VAT10'),
        const SizedBox(height: 24),
        const Text('Price List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: const [
                    Expanded(flex: 2, child: Text('Price List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(flex: 1, child: Text('Currency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(flex: 1, child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildPriceListRow('Retail', 'USD', '\$ 1,249.00'),
              const Divider(height: 1),
              _buildPriceListRow('Wholesale', 'USD', '\$ 1,050.00'),
              const Divider(height: 1),
              _buildPriceListRow('Dealer', 'USD', '\$ 980.00'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceListRow(String list, String curr, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(list, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 1, child: Text(curr, style: const TextStyle(fontSize: 13))),
          Expanded(flex: 1, child: Text(price, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildInventoryTab(dynamic item) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Inventory Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField('Managed by', 'Batch No.', isDropdown: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Valuation method', 'Moving Avg.', isDropdown: true)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Min. stock', '30 Units')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('Max. stock', '200 Units')),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Warehouse Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: const [
                    SizedBox(width: 20, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(flex: 3, child: Text('Warehouse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(flex: 2, child: Text('In Stock', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(flex: 2, child: Text('Committed', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Expanded(flex: 2, child: Text('Available', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildWarehouseRow('1', '01 - Main Warehouse', '128', '22', '106'),
              const Divider(height: 1),
              _buildWarehouseRow('2', '02 - Branch Warehouse', '45', '8', '37'),
              const Divider(height: 1),
              _buildWarehouseRow('3', '03 - Online Warehouse', '20', '0', '20'),
              const Divider(height: 1),
              _buildWarehouseRow('4', '04 - Return Warehouse', '5', '1', '4'),
              const Divider(height: 1),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text('Add Warehouse', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseRow(String no, String whs, String inStock, String comm, String avail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 20, child: Text(no, style: const TextStyle(fontSize: 12))),
          Expanded(flex: 3, child: Text(whs, style: const TextStyle(fontSize: 12))),
          Expanded(flex: 2, child: Text(inStock, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(comm, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text(avail, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
