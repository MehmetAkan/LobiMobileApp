class CategoryModel {
  final String id;
  final String name;
  final String svgPath; 

  CategoryModel({required this.id, required this.name, required this.svgPath});

  static List<CategoryModel> getMockCategories() {
    return [
      CategoryModel(
        id: '1',
        name: 'Konser',
        svgPath: 'assets/images/system/lobitext.svg',
      ),
      CategoryModel(
        id: '2',
        name: 'Tiyatro',
        svgPath: 'assets/images/system/lobitext.svg',
      ),
      CategoryModel(
        id: '3',
        name: 'Spor',
        svgPath: 'assets/images/system/lobitext.svg',
      ),
      CategoryModel(
        id: '4',
        name: 'Sinema',
        svgPath: 'assets/images/system/lobitext.svg',
      ),
      CategoryModel(
        id: '5',
        name: 'Sanat',
        svgPath: 'assets/images/system/lobitext.svg',
      ),
      CategoryModel(
        id: '6',
        name: 'Teknoloji',
        svgPath: 'assets/images/system/lobitext.svg',
      ),
      CategoryModel(
        id: '7',
        name: 'Yemek',
        svgPath: 'assets/images/system/lobitext.svg',
      ),
      CategoryModel(
        id: '8',
        name: 'Eğitim',
        svgPath: 'assets/images/system/lobitext.svg',
      ),
      CategoryModel(
        id: '9',
        name: 'Gezi',
        svgPath: 'assets/images/system/lobitext.svg',
      ),
      CategoryModel(
        id: '10',
        name: 'Sağlık',
        svgPath: 'assets/images/system/lobitext.svg',
      ),
    ];
  }
}
