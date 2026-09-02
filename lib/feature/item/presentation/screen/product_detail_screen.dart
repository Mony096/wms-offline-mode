import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wms_mobile/constant/style.dart';
import 'package:image_picker/image_picker.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic item;
  const ProductDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await _picker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          setState(() {
            _images.addAll(pickedFiles);
          });
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            _images.add(pickedFile);
          });
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(String text, int index) {
    bool isSelected = _tabController.index == index;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      margin: const EdgeInsets.only(left:2, top: 5),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF131A3F) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.only(left:10, right: 10),
              indicator: const BoxDecoration(), // Remove default indicator
              dividerColor: Colors.transparent, // Remove underline
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              tabs: [
                _buildTab("General", 0),
                _buildTab("Purchasing", 1),
                _buildTab("Sales", 2),
                _buildTab("Inventory", 3),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(item),
                _buildPurchasingTab(item),
                _buildSalesTab(item),
                _buildInventoryTab(item),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String value,
      {bool isDropdown = false}) {
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
                const Icon(Icons.keyboard_arrow_down,
                    size: 20, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralTab(dynamic item) {
    final String itemName = item['ItemName'] ?? '';
    final String itemCode = item['ItemCode'] ?? '';
    final bool isActive = item['Valid'] == 'tYES';
    final String itemGroup = item['ItemsGroupCode']?.toString() ?? '';
    final String remark = item['User_Text'] ?? '';
    final String mainBarcode = item['BarCode'] ?? '';
    final String inventoryUom = item['InventoryUOM'] ?? '';

    // Determine Item Type based on flags
    String itemType = 'Inventory';
    if (item['SalesItem'] == 'tYES' && item['PurchaseItem'] == 'tNO') {
      itemType = 'Sales';
    } else if (item['PurchaseItem'] == 'tYES' && item['SalesItem'] == 'tNO') {
      itemType = 'Purchasing';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Image Carousel Mock
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Stack(
            children: [
              if (_images.isEmpty)
                Center(
                  child: Icon(Icons.computer, size: 80, color: Colors.grey.shade300),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(_images[index].path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
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
                  child: Text(
                    _images.isEmpty ? '0/0' : '${_currentImageIndex + 1}/${_images.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt_outlined, size: 20),
                  ),
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
                    itemName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Code: $itemCode',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child:
                    _buildTextField('Item group', itemGroup, isDropdown: true)),
            const SizedBox(width: 16),
            Expanded(
                child:
                    _buildTextField('Item type', itemType, isDropdown: true)),
          ],
        ),
        const SizedBox(height: 16),
        // Barcode Table
        if (mainBarcode.isNotEmpty)
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                          flex: 1,
                          child: Text('No',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(
                          flex: 2,
                          child: Text('UoM',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(
                          flex: 4,
                          child: Text('Barcode',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                      SizedBox(width: 24), // For action icon
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildBarcodeRow('1', inventoryUom, mainBarcode),
              ],
            ),
          ),
        if (mainBarcode.isNotEmpty) const SizedBox(height: 16),
        if (remark.isNotEmpty) _buildTextField('Remark', remark),
      ],
    );
  }

  Widget _buildBarcodeRow(String no, String uom, String barcode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Expanded(
              flex: 1, child: Text(no, style: const TextStyle(fontSize: 13))),
          Expanded(
              flex: 2, child: Text(uom, style: const TextStyle(fontSize: 13))),
          Expanded(
              flex: 4,
              child: Text(barcode, style: const TextStyle(fontSize: 13))),
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
            Expanded(
                child: _buildTextField(
                    'Purchasing UoM', item['PurchaseUnit']?.toString() ?? '')),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField('Items/purch. unit',
                    item['PurchaseItemsPerUnit']?.toString() ?? '')),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
            'Preferred vendor', item['Mainsupplier']?.toString() ?? ''),
        const SizedBox(height: 16),
        _buildTextField(
            'Vendor catalog no', item['SupplierCatalogNo']?.toString() ?? ''),
        const SizedBox(height: 16),
        _buildTextField(
          'HS Code',
          item['ChapterID']?.toString() == '-1'
              ? ''
              : (item['ChapterID']?.toString() ?? ''),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField('Country of origin',
                    item['ItemCountryOrg']?.toString() ?? '')),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField(
                    'Lead time', item['LeadTime']?.toString() ?? '')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField('Min. order qty',
                    item['MinOrderQuantity']?.toString() ?? '')),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField('Tax category',
                    item['PurchaseVATGroup']?.toString() ?? '')),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Last purchase price', '-'),
      ],
    );
  }

  Widget _buildSalesTab(dynamic item) {
    List<dynamic> prices = item['ItemPrices'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
                child: _buildTextField(
                    'Sales UoM', item['SalesUnit']?.toString() ?? '')),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField('Items/sales unit',
                    item['SalesItemsPerUnit']?.toString() ?? '')),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
            'Tax category', item['SalesVATGroup']?.toString() ?? ''),
        const SizedBox(height: 24),
        const Text('Price List',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        if (prices.isNotEmpty)
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                          flex: 2,
                          child: Text('Price List',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(
                          flex: 1,
                          child: Text('Currency',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(
                          flex: 1,
                          child: Text('Price',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                  ),
                ),
                ...prices.where((p) => p['Price'] != 0.0).map((price) {
                  return Column(
                    children: [
                      const Divider(height: 1),
                      _buildPriceListRow(
                        price['PriceList'].toString(),
                        price['Currency']?.toString() ?? '',
                        price['Price'].toString(),
                      ),
                    ],
                  );
                }).toList(),
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
          Expanded(
              flex: 2, child: Text(list, style: const TextStyle(fontSize: 13))),
          Expanded(
              flex: 1, child: Text(curr, style: const TextStyle(fontSize: 13))),
          Expanded(
              flex: 1,
              child: Text(price,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildInventoryTab(dynamic item) {
    final String manageBy = item['ManageSerialNumbers'] == 'tYES'
        ? 'Serial No.'
        : item['ManageBatchNumbers'] == 'tYES'
            ? 'Batch No.'
            : 'None';

    List<dynamic> warehouses = item['ItemWarehouseInfoCollection'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Inventory Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child:
                    _buildTextField('Managed by', manageBy, isDropdown: true)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField('Valuation method',
                    item['CostAccountingMethod']?.toString() ?? '',
                    isDropdown: true)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField(
                    'Min. stock', item['MinInventory']?.toString() ?? '')),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField(
                    'Max. stock', item['MaxInventory']?.toString() ?? '')),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Warehouse Information',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        if (warehouses.isNotEmpty)
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(
                          width: 20,
                          child: Text('#',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(
                          flex: 3,
                          child: Text('Warehouse',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(
                          flex: 2,
                          child: Text('In Stock',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(
                          flex: 2,
                          child: Text('Committed',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                      Expanded(
                          flex: 2,
                          child: Text('Available',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                  ),
                ),
                ...warehouses.asMap().entries.map((entry) {
                  int idx = entry.key;
                  dynamic whs = entry.value;
                  double inStock = whs['InStock']?.toDouble() ?? 0.0;
                  double comm = whs['Committed']?.toDouble() ?? 0.0;
                  double avail = inStock - comm;
                  return Column(
                    children: [
                      const Divider(height: 1),
                      _buildWarehouseRow(
                        (idx + 1).toString(),
                        whs['WarehouseCode']?.toString() ?? '',
                        inStock.toStringAsFixed(0),
                        comm.toStringAsFixed(0),
                        avail.toStringAsFixed(0),
                      ),
                    ],
                  );
                }).toList(),
                const Divider(height: 1),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withOpacity(0.5),
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline,
                            size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text('Add Warehouse',
                            style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
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

  Widget _buildWarehouseRow(
      String no, String whs, String inStock, String comm, String avail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          SizedBox(
              width: 20, child: Text(no, style: const TextStyle(fontSize: 12))),
          Expanded(
              flex: 3, child: Text(whs, style: const TextStyle(fontSize: 12))),
          Expanded(
              flex: 2,
              child: Text(inStock,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text(comm,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text(avail,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
