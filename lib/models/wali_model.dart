class WaliModel {
  final int id;
  final String nama;
  final String wilayah;
  final String periode;
  final String ringkasan;
  final String konten;
  final String gambar;

  // Field Tambahan untuk Tabel Biodata & Silsilah
  final String namaLengkap;
  final String gelarNamaLain;
  final String asalUsulKelahiran;
  final String garisKeturunan;
  final String ayah;
  final String pasangIstri;
  final String keturunanUtama;
  final String wafatLokasiMakam;

  WaliModel({
    required this.id,
    required this.nama,
    required this.wilayah,
    required this.periode,
    required this.ringkasan,
    required this.konten,
    this.gambar = '',
    this.namaLengkap = '-',
    this.gelarNamaLain = '-',
    this.asalUsulKelahiran = '-',
    this.garisKeturunan = '-',
    this.ayah = '-',
    this.pasangIstri = '-',
    this.keturunanUtama = '-',
    this.wafatLokasiMakam = '-',
  });

  factory WaliModel.fromJson(Map<String, dynamic> json) {
    return WaliModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nama: json['nama']?.toString() ?? '',
      wilayah: json['wilayah']?.toString() ?? '',
      periode: json['periode']?.toString() ?? '',
      ringkasan: json['ringkasan']?.toString() ?? '',
      konten: json['konten']?.toString() ?? '',
      gambar: json['gambar']?.toString() ?? '',
      namaLengkap: json['namaLengkap']?.toString() ?? '-',
      gelarNamaLain: json['gelarNamaLain']?.toString() ?? '-',
      asalUsulKelahiran: json['asalUsulKelahiran']?.toString() ?? '-',
      garisKeturunan: json['garisKeturunan']?.toString() ?? '-',
      ayah: json['ayah']?.toString() ?? '-',
      pasangIstri: json['pasangIstri']?.toString() ?? '-',
      keturunanUtama: json['keturunanUtama']?.toString() ?? '-',
      wafatLokasiMakam: json['wafatLokasiMakam']?.toString() ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'wilayah': wilayah,
      'periode': periode,
      'ringkasan': ringkasan,
      'konten': konten,
      'gambar': gambar,
      'namaLengkap': namaLengkap,
      'gelarNamaLain': gelarNamaLain,
      'asalUsulKelahiran': asalUsulKelahiran,
      'garisKeturunan': garisKeturunan,
      'ayah': ayah,
      'pasangIstri': pasangIstri,
      'keturunanUtama': keturunanUtama,
      'wafatLokasiMakam': wafatLokasiMakam,
    };
  }
}
