import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MejorPrecioApp());

const aquaClaro = Color(0xFFBFE6E8);
const aquaMedio = Color(0xFF7CC6C9);
const azulOscuro = Color(0xFF0A2342);
const fondo = Color(0xFFF6FBFB);

class MejorPrecioApp extends StatelessWidget {
  const MejorPrecioApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MejorPrecio',
      theme: ThemeData(scaffoldBackgroundColor: fondo, primaryColor: azulOscuro, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class Tienda {
  final String nombre;
  final String urlBase;
  final List<String> categorias;
  final bool esMarketplace;
  final bool esSupermercado;
  final bool esTiendaBanco;
  final bool esTiendaBeneficios;
  Tienda(this.nombre, this.urlBase, this.categorias,
      {this.esMarketplace = false, this.esSupermercado = false, this.esTiendaBanco = false, this.esTiendaBeneficios = false});
  String get etiqueta {
    if (esTiendaBeneficios) return 'Club / Beneficios';
    if (esTiendaBanco) return 'Tienda de Banco';
    if (esSupermercado) return 'Supermercado';
    if (esMarketplace) return 'Marketplace';
    return 'Tienda oficial';
  }
  bool get esGeneral => esMarketplace || esSupermercado || esTiendaBanco || esTiendaBeneficios;
  String urlBusqueda(String query) {
    final q = Uri.encodeComponent(query);
    if (nombre == 'Mercado Libre') return 'https://articulo.mercadolibre.com.ar/_Search?q=$q';
    if (nombre == 'Carrefour') return 'https://www.carrefour.com.ar/$q';
    if (nombre == 'Coto') return 'https://www.cotodigital.com.ar/sitios/cdigi/busqueda?palabra=$q';
    if (nombre == 'Jumbo') return 'https://www.jumbo.com.ar/$q';
    if (nombre == 'Changomás') return 'https://www.changomas.com.ar/$q';
    if (nombre == 'Frávega') return 'https://www.fravega.com/l/?keyword=$q';
    if (nombre == 'Garbarino') return 'https://www.garbarino.com/search?query=$q';
    if (nombre == 'Musimundo') return 'https://www.musimundo.com/search?query=$q';
    if (nombre == 'Dexter') return 'https://www.dexter.com.ar/search/$q';
    if (nombre == 'Moov') return 'https://www.moov.com.ar/search/$q';
    if (nombre == 'Netshoes') return 'https://www.netshoes.com.ar/buscador?ns_cat=All&q=$q';
    if (nombre == 'Tienda BNA') return 'https://tiendabna.com.ar/catalogsearch/result/?q=$q';
    if (nombre == 'Tienda Galicia') return 'https://www.tiendagalicia.com.ar/catalogsearch/result/?q=$q';
    if (nombre == 'Tienda Santander') return 'https://www.tiendasantander.com.ar/catalogsearch/result/?q=$q';
    if (nombre == 'Tienda BBVA') return 'https://www.tiendabbva.com.ar/catalogsearch/result/?q=$q';
    if (nombre == 'Club La Nación') return 'https://club.lanacion.com.ar/buscar?q=$q';
    if (nombre == 'Tienda Naranja X') return 'https://tienda.naranjax.com/search/$q';
    return '$urlBase/search?q=$q';
  }
}

class Oferta {
  final Tienda tienda;
  final double precio;
  final double envio;
  final int cuotas;
  final bool envioGratis;
  final String urlProducto;
  final String disponibilidad;
  final bool esPrecioReal;
  Oferta(this.tienda, this.precio, this.envio, this.cuotas, this.envioGratis, this.urlProducto, this.disponibilidad, {this.esPrecioReal = true});
  double get total => precio + (envioGratis ? 0 : envio);
  double get cuota => cuotas > 0 ? total / cuotas : total;
}

class Producto {
  final String nombre;
  final String categoria;
  final String marca;
  final String specs;
  final List<Oferta> ofertas;
  Producto(this.nombre, this.categoria, this.marca, this.specs, this.ofertas);
}

final tiendasArgentina = [
  Tienda('Mercado Libre', 'https://articulo.mercadolibre.com.ar', ['Calzado', 'Auto', 'Hogar', 'Electrónica', 'Deportes', 'Belleza', 'Tecnología', 'Juguetes', 'Herramientas', 'Alimentos'], esMarketplace: true),
  Tienda('Carrefour', 'https://www.carrefour.com.ar', ['Hogar', 'Electrónica', 'Tecnología', 'Calzado', 'Deportes', 'Belleza', 'Alimentos', 'Limpieza'], esSupermercado: true),
  Tienda('Coto', 'https://www.cotodigital.com.ar', ['Hogar', 'Electrónica', 'Tecnología', 'Calzado', 'Deportes', 'Alimentos', 'Limpieza'], esSupermercado: true),
  Tienda('Jumbo', 'https://www.jumbo.com.ar', ['Hogar', 'Electrónica', 'Tecnología', 'Alimentos', 'Limpieza', 'Belleza'], esSupermercado: true),
  Tienda('Changomás', 'https://www.changomas.com.ar', ['Hogar', 'Electrónica', 'Tecnología', 'Alimentos'], esSupermercado: true),
  Tienda('Tienda BNA', 'https://tiendabna.com.ar', ['Electrónica', 'Tecnología', 'Hogar', 'Calzado', 'Deportes', 'Belleza'], esMarketplace: true, esTiendaBanco: true),
  Tienda('Tienda Galicia', 'https://www.tiendagalicia.com.ar', ['Electrónica', 'Tecnología', 'Hogar', 'Calzado', 'Deportes'], esMarketplace: true, esTiendaBanco: true),
  Tienda('Tienda Santander', 'https://www.tiendasantander.com.ar', ['Electrónica', 'Tecnología', 'Hogar', 'Calzado'], esMarketplace: true, esTiendaBanco: true),
  Tienda('Tienda BBVA', 'https://www.tiendabbva.com.ar', ['Electrónica', 'Tecnología', 'Hogar', 'Calzado'], esMarketplace: true, esTiendaBanco: true),
  Tienda('Club La Nación', 'https://club.lanacion.com.ar', ['Electrónica', 'Tecnología', 'Hogar', 'Calzado', 'Deportes', 'Belleza'], esMarketplace: true, esTiendaBeneficios: true),
  Tienda('Tienda Naranja X', 'https://tienda.naranjax.com', ['Electrónica', 'Tecnología', 'Hogar', 'Calzado', 'Deportes'], esMarketplace: true, esTiendaBeneficios: true),
  Tienda('Frávega', 'https://www.fravega.com', ['Hogar', 'Electrónica', 'Tecnología', 'Deportes']),
  Tienda('Garbarino', 'https://www.garbarino.com', ['Hogar', 'Electrónica', 'Tecnología']),
  Tienda('Musimundo', 'https://www.musimundo.com', ['Hogar', 'Electrónica', 'Tecnología']),
  Tienda('Dexter', 'https://www.dexter.com.ar', ['Calzado', 'Deportes']),
  Tienda('Moov', 'https://www.moov.com.ar', ['Calzado', 'Deportes']),
  Tienda('Netshoes', 'https://www.netshoes.com.ar', ['Calzado', 'Deportes']),
  Tienda('Norauto', 'https://www.norauto.com.ar', ['Auto']),
  Tienda('AutoZone', 'https://www.autozone.com.ar', ['Auto']),
  Tienda('Farmacity', 'https://www.farmacity.com', ['Belleza', 'Farmacia', 'Cuidado']),
];

List<Tienda> tiendasParaBuscar(String categoria) {
  final Set<Tienda> res = {};
  res.addAll(tiendasArgentina.where((t) => t.esGeneral));
  if (categoria != 'Todos') res.addAll(tiendasArgentina.where((t) => t.categorias.contains(categoria)));
  return res.toList();
}

class BuscadorService {
  static Future<List<Producto>> buscar({required String query, required String categoria, required String filtroTipo, required bool soloEnvioGratis, required bool soloCuotas}) async {
    if (query.trim().isEmpty) return [];
    List<Producto> resultados = [];
    try {
      final resp = await http.get(Uri.parse('https://api.mercadolibre.com/sites/MLA/search?q=${Uri.encodeComponent(query)}&limit=8'));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        for (final item in (data['results'] as List)) {
          final tiendaML = tiendasArgentina.firstWhere((t) => t.nombre == 'Mercado Libre');
          int cuotas = 1;
          final inst = item['installments'];
          if (inst != null && inst['quantity'] != null) cuotas = (inst['quantity'] as num).toInt();
          final envioGratis = item['shipping']?['free_shipping'] ?? false;
          final oferta = Oferta(tiendaML, (item['price'] as num).toDouble(), envioGratis ? 0 : 1800, cuotas, envioGratis, item['permalink'] ?? '', (item['available_quantity'] ?? 0) > 0 ? 'En stock' : 'Sin stock', esPrecioReal: true);
          if (soloEnvioGratis && !oferta.envioGratis) continue;
          if (soloCuotas && oferta.cuotas <= 1) continue;
          resultados.add(Producto(item['title'] ?? query, categoria, '', item['title'] ?? query, [oferta]));
        }
      }
    } catch (e) {
      debugPrint('Error ML: $e');
    }
    if (resultados.isNotEmpty) {
      final primerProducto = resultados.first;
      final tiendas = tiendasParaBuscar(categoria);
      for (final tienda in tiendas) {
        if (tienda.nombre == 'Mercado Libre') continue;
        if (!pasaFiltroTipoTienda(tienda, filtroTipo)) continue;
        primerProducto.ofertas.add(Oferta(tienda, 0, 0, 1, false, tienda.urlBusqueda(query), 'Ver precio en tienda', esPrecioReal: false));
      }
    } else {
      final tiendas = tiendasParaBuscar(categoria);
      List<Oferta> ofertas = tiendas.where((t) => pasaFiltroTipoTienda(t, filtroTipo)).map((t) => Oferta(t, 0, 0, 1, false, t.urlBusqueda(query), 'Ver precio en tienda', esPrecioReal: false)).toList();
      if (ofertas.isNotEmpty) resultados.add(Producto(query, categoria, '', query, ofertas));
    }
    return resultados;
  }
  static bool pasaFiltroTipoTienda(Tienda t, String filtro) {
    if (filtro == 'Todos') return true;
    if (filtro == 'Supermercados') return t.esSupermercado;
    if (filtro == 'Bancos') return t.esTiendaBanco;
    if (filtro == 'Clubes / Tarjetas') return t.esTiendaBeneficios;
    if (filtro == 'Marketplaces') return t.esMarketplace && !t.esGeneral;
    if (filtro == 'Oficiales') return !t.esGeneral;
    return true;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String busqueda = '';
  String categoria = 'Todos';
  String filtroTipo = 'Todos';
  bool soloEnvioGratis = false;
  bool soloCuotas = false;
  List<Producto> resultados = [];
  bool buscando = false;
  bool yaBusco = false;
  final categoriasDisponibles = ['Todos', 'Calzado', 'Auto', 'Hogar', 'Electrónica', 'Tecnología', 'Deportes', 'Belleza', 'Alimentos', 'Herramientas', 'Juguetes', 'Viajes'];
  final filtrosTipo = ['Todos', 'Supermercados', 'Bancos', 'Clubes / Tarjetas', 'Marketplaces', 'Oficiales'];
  Future<void> hacerBusqueda() async {
    if (busqueda.trim().isEmpty) return;
    setState(() { buscando = true; yaBusco = true; });
    final res = await BuscadorService.buscar(query: busqueda, categoria: categoria, filtroTipo: filtroTipo, soloEnvioGratis: soloEnvioGratis, soloCuotas: soloCuotas);
    setState(() { resultados = res; buscando = false; });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: fondo, elevation: 0, title: const Row(children: [Icon(Icons.verified, color: aquaMedio, size: 28), SizedBox(width: 6), Text('MejorPrecio', style: TextStyle(color: azulOscuro, fontWeight: FontWeight.bold))])),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(onChanged: (v) => busqueda = v, onSubmitted: (_) => hacerBusqueda(), decoration: InputDecoration(hintText: 'Buscá cualquier cosa...', prefixIcon: const Icon(Icons.search, color: azulOscuro), suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward, color: azulOscuro), onPressed: hacerBusqueda), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: aquaClaro)))),
          const SizedBox(height: 8),
          const Text('Gratis. Solo informamos dónde comprar. No vendemos ni cobramos en la app.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          if (busqueda.isNotEmpty) Text('Buscando en ${tiendasParaBuscar(categoria).length} tiendas', style: const TextStyle(fontSize: 12, color: azulOscuro)),
        ])),
        SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: categoriasDisponibles.map((c) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(c), selected: categoria == c, selectedColor: aquaClaro, onSelected: (_) => setState(() => categoria = c)))).toList())),
        const SizedBox(height: 8),
        SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: filtrosTipo.map((f) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(f), selected: filtroTipo == f, selectedColor: aquaClaro, onSelected: (_) => setState(() => filtroTipo = f)))).toList())),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [FilterChip(label: const Text('Envío gratis'), selected: soloEnvioGratis, selectedColor: aquaClaro, onSelected: (v) => setState(() => soloEnvioGratis = v)), const SizedBox(width: 8), FilterChip(label: const Text('Cuotas'), selected: soloCuotas, selectedColor: aquaClaro, onSelected: (v) => setState(() => soloCuotas = v))])),
        Expanded(child: buscando ? const Center(child: CircularProgressIndicator(color: aquaMedio)) : !yaBusco ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Buscá lo que quieras y te mostramos dónde comprarlo al mejor precio total.', textAlign: TextAlign.center))) : resultados.isEmpty ? const Center(child: Text('Sin resultados. Probá con otra búsqueda.')) : ListView.builder(itemCount: resultados.length, itemBuilder: (context, i) {
          final p = resultados[i];
          final reales = p.ofertas.where((o) => o.esPrecioReal).toList()..sort((a, b) => a.total.compareTo(b.total));
          final mejor = reales.isNotEmpty ? reales.first : p.ofertas.first;
          return Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), color: Colors.white, child: ListTile(title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: azulOscuro)), subtitle: Text(reales.isNotEmpty ? 'Desde \$${mejor.total.toStringAsFixed(0)} en ${mejor.tienda.nombre} • ${mejor.cuotas} cuotas de \$${mejor.cuota.toStringAsFixed(0)}\n+ ${p.ofertas.length} tiendas para comparar' : 'Ver precio en ${p.ofertas.length} tiendas'), isThreeLine: true, trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: aquaMedio), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleScreen(producto: p)))));
        })),
      ]),
    );
  }
}

class DetalleScreen extends StatelessWidget {
  final Producto producto;
  const DetalleScreen({super.key, required this.producto});
  Future<void> abrir(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  @override
  Widget build(BuildContext context) {
    final reales = [...producto.ofertas.where((o) => o.esPrecioReal)]..sort((a, b) => a.total.compareTo(b.total));
    final otras = [...producto.ofertas.where((o) => !o.esPrecioReal)];
    return Scaffold(
      appBar: AppBar(title: Text(producto.nombre, maxLines: 1, overflow: TextOverflow.ellipsis), backgroundColor: fondo, foregroundColor: azulOscuro),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (reales.isNotEmpty) Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: aquaClaro, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(producto.nombre, style: const TextStyle(color: azulOscuro, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text('Mejor precio real: \$${reales.first.total.toStringAsFixed(0)} en ${reales.first.tienda.nombre}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: azulOscuro)), Text('${reales.first.cuotas} cuotas de \$${reales.first.cuota.toStringAsFixed(0)} • ${reales.first.disponibilidad}')])),
        const SizedBox(height: 16),
        if (reales.isNotEmpty) const Text('Precios reales - Mercado Libre', style: TextStyle(fontWeight: FontWeight.bold, color: azulOscuro)),
        ...reales.asMap().entries.map((e) {
          final o = e.value;
          return Card(color: e.key == 0 ? aquaClaro : Colors.white, child: ListTile(title: Text('${o.tienda.nombre} • \$${o.total.toStringAsFixed(0)}'), subtitle: Text('Precio: \$${o.precio.toStringAsFixed(0)} • Envío: ${o.envioGratis ? "Gratis" : "\$${o.envio.toStringAsFixed(0)}"} • ${o.cuotas} cuotas de \$${o.cuota.toStringAsFixed(0)}'), trailing: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: azulOscuro, foregroundColor: Colors.white), onPressed: () => abrir(o.urlProducto), child: const Text('Ver'))));
        }),
        const SizedBox(height: 16),
        const Text('También comparar en otras tiendas', style: TextStyle(fontWeight: FontWeight.bold, color: azulOscuro)),
        const Text('Te lleva a la búsqueda exacta en cada tienda, sin inventar precios.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        ...otras.map((o) => Card(child: ListTile(title: Text(o.tienda.nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: azulOscuro)), subtitle: Text(o.tienda.etiqueta), trailing: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: azulOscuro, foregroundColor: Colors.white), onPressed: () => abrir(o.urlProducto), child: const Text('Buscar'))))),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alerta creada: te avisamos si baja'))), icon: const Icon(Icons.notifications, color: azulOscuro), label: const Text('Avisame si baja de precio', style: TextStyle(color: azulOscuro))),
      ]),
    );
  }
}
