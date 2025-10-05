import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class RegionPage extends StatefulWidget {
  final String regionName;

  RegionPage({Key? key, required this.regionName}) : super(key: key);

  @override
  State<RegionPage> createState() => _RegionPageState();
}

class _RegionPageState extends State<RegionPage> with TickerProviderStateMixin {
  Position? _userPosition;

  // 📍 Liste statique des pharmacies par région
  final Map<String, List<Map<String, dynamic>>> pharmaciesParRegion = {
    "Dakar": [
    {"nom": "Pharmacie Centrale", "adresse": "Avenue Blaise Diagne, Dakar", "telephone": "+221338214567", "lat": 14.6937, "lng": -17.4441},
    {"nom": "Pharmacie de la Paix", "adresse": "Place de l’Indépendance, Dakar", "telephone": "+221338227890", "lat": 14.6972, "lng": -17.4443},
    {"nom": "Pharmacie Médina", "adresse": "Rue 6, Médina, Dakar", "telephone": "+221338231234", "lat": 14.6925, "lng": -17.4460},
    {"nom": "Pharmacie Fann", "adresse": "Boulevard du Général de Gaulle, Fann, Dakar", "telephone": "+221338245678", "lat": 14.6865, "lng": -17.4550},
    {"nom": "Pharmacie Liberté 6", "adresse": "Route de Ouakam, Liberté 6, Dakar", "telephone": "+221338259876", "lat": 14.7132, "lng": -17.4661},
    {"nom": "Pharmacie Mermoz", "adresse": "Rue Mermoz, Dakar", "telephone": "+221338222333", "lat": 14.6980, "lng": -17.4300},
    {"nom": "Pharmacie Pikine Nord", "adresse": "Boulevard Général de Gaulle, Pikine", "telephone": "+221338200111", "lat": 14.7470, "lng": -17.4000},
    {"nom": "Pharmacie Yoff", "adresse": "Route de Yoff, Dakar", "telephone": "+221338233444", "lat": 14.7480, "lng": -17.4940},
    {"nom": "Pharmacie Ngor", "adresse": "Village de Ngor, Dakar", "telephone": "+221338244555", "lat": 14.7670, "lng": -17.5040},
    {"nom": "Pharmacie Ouakam", "adresse": "Route de Ouakam, Dakar", "telephone": "+221338255666", "lat": 14.7300, "lng": -17.4700},
    {"nom": "Pharmacie Hann", "adresse": "Boulevard Hann, Dakar", "telephone": "+221338266777", "lat": 14.7150, "lng": -17.4705},
    {"nom": "Pharmacie Mbao", "adresse": "Route de Mbao, Dakar", "telephone": "+221338277888", "lat": 14.7800, "lng": -17.3800},
    {"nom": "Pharmacie Parcelles Assainies", "adresse": "Rue des Parcelles, Dakar", "telephone": "+221338288999", "lat": 14.7490, "lng": -17.4100},
    {"nom": "Pharmacie Grand Yoff", "adresse": "Boulevard de Grand Yoff, Dakar", "telephone": "+221338299000", "lat": 14.7155, "lng": -17.4600},
    {"nom": "Pharmacie Fass", "adresse": "Rue de Fass, Dakar", "telephone": "+221338211111", "lat": 14.7000, "lng": -17.4450},
  ],

    "Thiès": [
       {"nom": "Pharmacie Parcelloise", "adresse": "Parcelles assainies U1, Thiès", "telephone": "+221336543210", "lat": 14.77370, "lng": -16.93465},
    {"nom": "Pharmacie du Camp", "adresse": "Derrière cimetière de Mbambara Ali lo, Thiès", "telephone": "+221336512345", "lat": 14.78620, "lng": -16.91754},
    {"nom": "Pharmacie du Ronp Point Nguinth", "adresse": "Route de Guinth, Thiès", "telephone": "+221336578901", "lat": 14.80123, "lng": -16.92639},
    {"nom": "Pharmacie de la Téranga", "adresse": "Rue Hophouet Boigny, Thiès", "telephone": "+221336578902", "lat": 14.79397, "lng": -16.92921},
    {"nom": "Pharmacie Thiès Centre", "adresse": "Avenue Léopold Sédar Senghor, Thiès", "telephone": "+221336500111", "lat": 14.7900, "lng": -16.9300},
    {"nom": "Pharmacie Mbour", "adresse": "Route de Mbour, Thiès", "telephone": "+221336501234", "lat": 14.7800, "lng": -16.9100},
    {"nom": "Pharmacie Tivaouane", "adresse": "Rue Tivaouane, Thiès", "telephone": "+221336502345", "lat": 14.7850, "lng": -16.9150},
    {"nom": "Pharmacie Keur Momar Sarr", "adresse": "Avenue Keur Momar Sarr, Thiès", "telephone": "+221336503456", "lat": 14.7720, "lng": -16.9250},
    {"nom": "Pharmacie Thiès Sud", "adresse": "Route Thiès Sud, Thiès", "telephone": "+221336504567", "lat": 14.7700, "lng": -16.9350},
    {"nom": "Pharmacie Thiès Nord", "adresse": "Rue Thiès Nord, Thiès", "telephone": "+221336505678", "lat": 14.8000, "lng": -16.9400},
    {"nom": "Pharmacie Notto", "adresse": "Village de Notto, Thiès", "telephone": "+221336506789", "lat": 14.7905, "lng": -16.9500},
    {"nom": "Pharmacie Thiès Ouest", "adresse": "Avenue Thiès Ouest, Thiès", "telephone": "+221336507890", "lat": 14.7805, "lng": -16.9600},
    {"nom": "Pharmacie Thiès Est", "adresse": "Rue Thiès Est, Thiès", "telephone": "+221336508901", "lat": 14.7750, "lng": -16.9700},
    {"nom": "Pharmacie Pout", "adresse": "Route de Pout, Thiès", "telephone": "+221336509012", "lat": 14.7600, "lng": -16.9800},
    {"nom": "Pharmacie Keur Samba Guèye", "adresse": "Avenue Keur Samba Guèye, Thiès", "telephone": "+221336510123", "lat": 14.7500, "lng": -16.9850},
    ],

    "Diourbel": [
        {"nom": "Pharmacie Diourbel Centre", "adresse": "Avenue El Hadji Malick, Diourbel", "telephone": "+221338760001", "lat": 14.6625, "lng": -16.2333},
  {"nom": "Pharmacie Touba Sandaga", "adresse": "Marché Sandaga, Touba", "telephone": "+221338760002", "lat": 14.8561, "lng": -15.8756},
  {"nom": "Pharmacie Darou Khoudoss", "adresse": "Darou Khoudoss, Touba", "telephone": "+221338760003", "lat": 14.8580, "lng": -15.8945},
  {"nom": "Pharmacie Mbacké", "adresse": "Centre-ville, Mbacké", "telephone": "+221338760004", "lat": 14.7953, "lng": -15.9087},
  {"nom": "Pharmacie Gare Diourbel", "adresse": "Rue de la Gare, Diourbel", "telephone": "+221338760005", "lat": 14.6640, "lng": -16.2370},
  {"nom": "Pharmacie Baay Laaw", "adresse": "Touba Baay Laaw", "telephone": "+221338760006", "lat": 14.8370, "lng": -15.8850},
  {"nom": "Pharmacie Keur Cheikh", "adresse": "Quartier Keur Cheikh, Mbacké", "telephone": "+221338760007", "lat": 14.7900, "lng": -15.9150},
  {"nom": "Pharmacie Ndame", "adresse": "Quartier Ndame, Touba", "telephone": "+221338760008", "lat": 14.8500, "lng": -15.8800},
  {"nom": "Pharmacie Thially", "adresse": "Quartier Thially, Diourbel", "telephone": "+221338760009", "lat": 14.6700, "lng": -16.2400},
  {"nom": "Pharmacie HLM Diourbel", "adresse": "Quartier HLM, Diourbel", "telephone": "+221338760010", "lat": 14.6650, "lng": -16.2450},
  {"nom": "Pharmacie Ngabou", "adresse": "Ngabou, Touba", "telephone": "+221338760011", "lat": 14.8450, "lng": -15.8700},
  {"nom": "Pharmacie Keur Serigne", "adresse": "Quartier Keur Serigne, Diourbel", "telephone": "+221338760012", "lat": 14.6600, "lng": -16.2300},
  {"nom": "Pharmacie Médina Mbacké", "adresse": "Médina, Mbacké", "telephone": "+221338760013", "lat": 14.7980, "lng": -15.9050},
  {"nom": "Pharmacie Darou Miname", "adresse": "Touba Darou Miname", "telephone": "+221338760014", "lat": 14.8520, "lng": -15.8820},
  {"nom": "Pharmacie Kaël", "adresse": "Kaël, Diourbel", "telephone": "+221338760015", "lat": 14.7830, "lng": -15.9600},
    ],
    "Saint-Louis": [
       {"nom": "Pharmacie Saint-Louis", "adresse": "Rue de la Liberté, Saint-Louis", "telephone": "+221338800111", "lat": 16.0156, "lng": -16.5004},
    {"nom": "Pharmacie Al Hamdou Lilah", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338800222", "lat": 16.0160, "lng": -16.5010},
    {"nom": "Pharmacie Bouchraa", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338800333", "lat": 16.0165, "lng": -16.5020},
    {"nom": "Pharmacie Château d'Eau", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338800444", "lat": 16.0170, "lng": -16.5030},
    {"nom": "Pharmacie Mame Madia", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338800555", "lat": 16.0175, "lng": -16.5040},
    {"nom": "Pharmacie Mame Yacine Bop", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338800666", "lat": 16.0180, "lng": -16.5050},
    {"nom": "Pharmacie Papa Latsouk", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338800777", "lat": 16.0185, "lng": -16.5060},
    {"nom": "Pharmacie Pascaline", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338800888", "lat": 16.0190, "lng": -16.5070},
    {"nom": "Pharmacie Guet Ndar", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338800999", "lat": 16.0195, "lng": -16.5080},
    {"nom": "Pharmacie Guet Ndarienne", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338801000", "lat": 16.0200, "lng": -16.5090},
    {"nom": "Pharmacie Gouye Seddelé", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338801111", "lat": 16.0205, "lng": -16.5100},
    {"nom": "Pharmacie Malang Lys", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338801222", "lat": 16.0210, "lng": -16.5110},
    {"nom": "Pharmacie Serigne Abdou", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338801333", "lat": 16.0215, "lng": -16.5120},
    {"nom": "Pharmacie Khadimou Rassoul", "adresse": "Saint-Louis, Saint-Louis", "telephone": "+221338801444", "lat": 16.0220, "lng": -16.5130},
    ],
    "Louga": [

       {"nom": "Pharmacie Louga Centre", "adresse": "Avenue de la République, Louga", "telephone": "+221339600001", "lat": 15.6100, "lng": -16.2250},
  {"nom": "Pharmacie Ndiaye", "adresse": "Marché central, Louga", "telephone": "+221339600002", "lat": 15.6150, "lng": -16.2300},
  {"nom": "Pharmacie Koki", "adresse": "Centre-ville, Koki", "telephone": "+221339600003", "lat": 15.7500, "lng": -16.0830},
  {"nom": "Pharmacie Sakal", "adresse": "Quartier Sakal, Louga", "telephone": "+221339600004", "lat": 15.6830, "lng": -16.4000},
  {"nom": "Pharmacie Dahra", "adresse": "Centre-ville, Dahra", "telephone": "+221339600005", "lat": 15.3480, "lng": -15.4760},
  {"nom": "Pharmacie Linguère", "adresse": "Rue principale, Linguère", "telephone": "+221339600006", "lat": 15.3940, "lng": -15.1230},
  {"nom": "Pharmacie Keur Momar Sarr", "adresse": "Keur Momar Sarr, Louga", "telephone": "+221339600007", "lat": 15.8160, "lng": -16.0800},
  {"nom": "Pharmacie Ndiambour", "adresse": "Quartier Ndiambour, Louga", "telephone": "+221339600008", "lat": 15.6200, "lng": -16.2400},
  {"nom": "Pharmacie Léona", "adresse": "Quartier Léona, Louga", "telephone": "+221339600009", "lat": 15.6180, "lng": -16.2350},
  {"nom": "Pharmacie HLM Louga", "adresse": "Quartier HLM, Louga", "telephone": "+221339600010", "lat": 15.6220, "lng": -16.2450},
  {"nom": "Pharmacie Mbeuleukhé", "adresse": "Village de Mbeuleukhé", "telephone": "+221339600011", "lat": 15.4800, "lng": -15.9500},
  {"nom": "Pharmacie Thiamène", "adresse": "Quartier Thiamène, Louga", "telephone": "+221339600012", "lat": 15.6160, "lng": -16.2380},
  {"nom": "Pharmacie Mbédiène", "adresse": "Village de Mbédiène", "telephone": "+221339600013", "lat": 15.7900, "lng": -16.3000},
  {"nom": "Pharmacie Djoloff", "adresse": "Quartier Djoloff, Louga", "telephone": "+221339600014", "lat": 15.6250, "lng": -16.2200},
  {"nom": "Pharmacie Mbadakhoune", "adresse": "Village de Mbadakhoune, Louga", "telephone": "+221339600015", "lat": 15.7000, "lng": -16.0500},

    ],

    "Matam": [
      {"nom": "Pharmacie Matam Centre", "adresse": "Route nationale, Matam", "telephone": "+221339700001", "lat": 15.6500, "lng": -13.2500},
  {"nom": "Pharmacie Ourossogui", "adresse": "Centre-ville, Ourossogui", "telephone": "+221339700002", "lat": 15.6000, "lng": -13.3160},
  {"nom": "Pharmacie Kanel", "adresse": "Rue principale, Kanel", "telephone": "+221339700003", "lat": 15.4930, "lng": -13.1760},
  {"nom": "Pharmacie Thilogne", "adresse": "Marché central, Thilogne", "telephone": "+221339700004", "lat": 15.2770, "lng": -13.0330},
  {"nom": "Pharmacie Ranérou", "adresse": "Route nationale, Ranérou", "telephone": "+221339700005", "lat": 15.3000, "lng": -12.9500},
  {"nom": "Pharmacie Wouro Sidy", "adresse": "Quartier Wouro Sidy, Matam", "telephone": "+221339700006", "lat": 15.6550, "lng": -13.2400},
  {"nom": "Pharmacie Sinthiou Bamambé", "adresse": "Village Sinthiou Bamambé", "telephone": "+221339700007", "lat": 15.4830, "lng": -13.3670},
  {"nom": "Pharmacie Agnam Civol", "adresse": "Village Agnam Civol", "telephone": "+221339700008", "lat": 15.2770, "lng": -13.1170},
  {"nom": "Pharmacie Ogo", "adresse": "Quartier Ogo, Matam", "telephone": "+221339700009", "lat": 15.6830, "lng": -13.2830},
  {"nom": "Pharmacie Bokidiawé", "adresse": "Centre Bokidiawé", "telephone": "+221339700010", "lat": 15.3360, "lng": -13.0080},
  {"nom": "Pharmacie Ouro Mody", "adresse": "Village Ouro Mody", "telephone": "+221339700011", "lat": 15.4260, "lng": -13.2420},
  {"nom": "Pharmacie Sadel", "adresse": "Village Sadel", "telephone": "+221339700012", "lat": 15.3100, "lng": -12.9170},
  {"nom": "Pharmacie Thiaméne Pass", "adresse": "Quartier Thiaméne, Matam", "telephone": "+221339700013", "lat": 15.6450, "lng": -13.2600},
  {"nom": "Pharmacie Vélingara Matam", "adresse": "Village Vélingara Matam", "telephone": "+221339700014", "lat": 15.5550, "lng": -13.1550},
  {"nom": "Pharmacie Ndioum", "adresse": "Quartier Ndioum, Matam", "telephone": "+221339700015", "lat": 15.3160, "lng": -13.1350},
    ],
    "Tambacounda": [
      {"nom": "Pharmacie Tambacounda Centre", "adresse": "Avenue du Commerce, Tambacounda", "telephone": "+221333940001", "lat": 13.7666, "lng": -13.6666},
  {"nom": "Pharmacie Dépôt", "adresse": "Quartier Dépôt, Tambacounda", "telephone": "+221333940002", "lat": 13.7680, "lng": -13.6650},
  {"nom": "Pharmacie Escale", "adresse": "Quartier Escale, Tambacounda", "telephone": "+221333940003", "lat": 13.7700, "lng": -13.6700},
  {"nom": "Pharmacie Plateau", "adresse": "Quartier Plateau, Tambacounda", "telephone": "+221333940004", "lat": 13.7720, "lng": -13.6670},
  {"nom": "Pharmacie Pont", "adresse": "Avenue Pont, Tambacounda", "telephone": "+221333940005", "lat": 13.7690, "lng": -13.6680},
  {"nom": "Pharmacie Gourel", "adresse": "Quartier Gourel, Tambacounda", "telephone": "+221333940006", "lat": 13.7740, "lng": -13.6630},
  {"nom": "Pharmacie Liberté", "adresse": "Quartier Liberté, Tambacounda", "telephone": "+221333940007", "lat": 13.7730, "lng": -13.6690},
  {"nom": "Pharmacie Kothiary", "adresse": "Route de Kothiary, Tambacounda", "telephone": "+221333940008", "lat": 13.7330, "lng": -13.6330},
  {"nom": "Pharmacie Missirah", "adresse": "Centre Missirah, Tambacounda", "telephone": "+221333940009", "lat": 13.7160, "lng": -13.5000},
  {"nom": "Pharmacie Dialacoto", "adresse": "Village Dialacoto, Tambacounda", "telephone": "+221333940010", "lat": 13.6160, "lng": -13.2830},
  {"nom": "Pharmacie Goudiry", "adresse": "Route principale, Goudiry", "telephone": "+221333940011", "lat": 14.1830, "lng": -12.7160},
  {"nom": "Pharmacie Koumpentoum", "adresse": "Centre Koumpentoum, Tambacounda", "telephone": "+221333940012", "lat": 13.9830, "lng": -14.0660},
  {"nom": "Pharmacie Maka Koulibantang", "adresse": "Village Maka Koulibantang, Tambacounda", "telephone": "+221333940013", "lat": 13.7160, "lng": -12.8830},
  {"nom": "Pharmacie Bakel", "adresse": "Quartier central, Bakel", "telephone": "+221333940014", "lat": 14.9000, "lng": -12.4660},
  {"nom": "Pharmacie Kidira", "adresse": "Route principale, Kidira", "telephone": "+221333940015", "lat": 14.4500, "lng": -12.2160},
    ],
    "Kédougou": [
        {"nom": "Pharmacie Kédougou Centre", "adresse": "Avenue de la République, Kédougou", "telephone": "+221333950001", "lat": 12.5667, "lng": -12.1833},
  {"nom": "Pharmacie Hôpital", "adresse": "Près de l’hôpital régional, Kédougou", "telephone": "+221333950002", "lat": 12.5680, "lng": -12.1840},
  {"nom": "Pharmacie Silo", "adresse": "Quartier Silo, Kédougou", "telephone": "+221333950003", "lat": 12.5650, "lng": -12.1850},
  {"nom": "Pharmacie Saré Yoba", "adresse": "Village Saré Yoba, Kédougou", "telephone": "+221333950004", "lat": 12.5600, "lng": -12.1900},
  {"nom": "Pharmacie Saré Koundia", "adresse": "Village Saré Koundia, Kédougou", "telephone": "+221333950005", "lat": 12.5620, "lng": -12.1880},
  {"nom": "Pharmacie Thiolomé", "adresse": "Quartier Thiolomé, Kédougou", "telephone": "+221333950006", "lat": 12.5640, "lng": -12.1820},
  {"nom": "Pharmacie Bandafassi", "adresse": "Village Bandafassi, Kédougou", "telephone": "+221333950007", "lat": 12.5500, "lng": -12.2000},
  {"nom": "Pharmacie Dindéfello", "adresse": "Village Dindéfello, Kédougou", "telephone": "+221333950008", "lat": 12.5400, "lng": -12.2100},
  {"nom": "Pharmacie Salémata", "adresse": "Centre Salémata, Kédougou", "telephone": "+221333950009", "lat": 12.5200, "lng": -12.2200},
  {"nom": "Pharmacie Dar Salam", "adresse": "Quartier Dar Salam, Kédougou", "telephone": "+221333950010", "lat": 12.5660, "lng": -12.1750},
  {"nom": "Pharmacie Ethiopienne", "adresse": "Quartier Ethiopienne, Kédougou", "telephone": "+221333950011", "lat": 12.5670, "lng": -12.1780},
  {"nom": "Pharmacie Salémata Nord", "adresse": "Route Salémata Nord, Kédougou", "telephone": "+221333950012", "lat": 12.5230, "lng": -12.2250},
  {"nom": "Pharmacie Kédougou Sud", "adresse": "Quartier Sud, Kédougou", "telephone": "+221333950013", "lat": 12.5590, "lng": -12.1870},
  {"nom": "Pharmacie Mandina", "adresse": "Village Mandina, Kédougou", "telephone": "+221333950014", "lat": 12.5510, "lng": -12.1950},
  {"nom": "Pharmacie Tomboronkoto", "adresse": "Village Tomboronkoto, Kédougou", "telephone": "+221333950015", "lat": 12.5450, "lng": -12.1980},
    ],
    "Kaffrine": [
       {"nom": "Pharmacie Kaffrine Centre", "adresse": "Avenue de la Gare, Kaffrine", "telephone": "+221339700001", "lat": 14.1000, "lng": -15.5500},
  {"nom": "Pharmacie Diamaguène", "adresse": "Quartier Diamaguène, Kaffrine", "telephone": "+221339700002", "lat": 14.1050, "lng": -15.5600},
  {"nom": "Pharmacie Médina", "adresse": "Quartier Médina, Kaffrine", "telephone": "+221339700003", "lat": 14.1100, "lng": -15.5450},
  {"nom": "Pharmacie Birkelane", "adresse": "Centre-ville, Birkelane", "telephone": "+221339700004", "lat": 14.2000, "lng": -15.4500},
  {"nom": "Pharmacie Malem Hodar", "adresse": "Village de Malem Hodar, Kaffrine", "telephone": "+221339700005", "lat": 14.2500, "lng": -15.6000},
  {"nom": "Pharmacie Koungheul", "adresse": "Centre-ville, Koungheul", "telephone": "+221339700006", "lat": 13.9830, "lng": -14.8000},
  {"nom": "Pharmacie Nganda", "adresse": "Village de Nganda, Kaffrine", "telephone": "+221339700007", "lat": 14.3160, "lng": -15.7160},
  {"nom": "Pharmacie Keur Mboucki", "adresse": "Village de Keur Mboucki, Kaffrine", "telephone": "+221339700008", "lat": 14.1830, "lng": -15.3660},
  {"nom": "Pharmacie Diamal", "adresse": "Village de Diamal, Kaffrine", "telephone": "+221339700009", "lat": 14.2160, "lng": -15.5000},
  {"nom": "Pharmacie Lour Escale", "adresse": "Centre Lour Escale, Kaffrine", "telephone": "+221339700010", "lat": 14.1160, "lng": -15.2330},
  {"nom": "Pharmacie Mbégué", "adresse": "Village de Mbégué, Kaffrine", "telephone": "+221339700011", "lat": 14.3160, "lng": -15.5660},
  {"nom": "Pharmacie Ndioum Ngainth", "adresse": "Village Ndioum Ngainth, Kaffrine", "telephone": "+221339700012", "lat": 14.2330, "lng": -15.7000},
  {"nom": "Pharmacie Kahi", "adresse": "Village de Kahi, Kaffrine", "telephone": "+221339700013", "lat": 14.1330, "lng": -15.4330},
  {"nom": "Pharmacie Maka Yop", "adresse": "Village de Maka Yop, Kaffrine", "telephone": "+221339700014", "lat": 14.0330, "lng": -15.6160},
  {"nom": "Pharmacie Touba Kaffrine", "adresse": "Quartier Touba, Kaffrine", "telephone": "+221339700015", "lat": 14.1200, "lng": -15.5700},
    ],
    "Kaolack": [
       {"nom": "Pharmacie Kaolack Centre", "adresse": "Rue du Commerce, Kaolack", "telephone": "+221339800001", "lat": 14.1500, "lng": -16.0700},
  {"nom": "Pharmacie Médina Baye", "adresse": "Quartier Médina Baye, Kaolack", "telephone": "+221339800002", "lat": 14.1550, "lng": -16.0750},
  {"nom": "Pharmacie Kahone", "adresse": "Route de Kahone, Kaolack", "telephone": "+221339800003", "lat": 14.1830, "lng": -16.0500},
  {"nom": "Pharmacie Léona", "adresse": "Quartier Léona, Kaolack", "telephone": "+221339800004", "lat": 14.1450, "lng": -16.0600},
  {"nom": "Pharmacie Abattoirs", "adresse": "Avenue des Abattoirs, Kaolack", "telephone": "+221339800005", "lat": 14.1400, "lng": -16.0650},
  {"nom": "Pharmacie Sibassor", "adresse": "Village de Sibassor, Kaolack", "telephone": "+221339800006", "lat": 14.2160, "lng": -16.0830},
  {"nom": "Pharmacie Ndoffane", "adresse": "Ndoffane, Kaolack", "telephone": "+221339800007", "lat": 14.2330, "lng": -16.3830},
  {"nom": "Pharmacie Ngane", "adresse": "Quartier Ngane, Kaolack", "telephone": "+221339800008", "lat": 14.1470, "lng": -16.0800},
  {"nom": "Pharmacie Médina Mbaba", "adresse": "Médina Mbaba, Kaolack", "telephone": "+221339800009", "lat": 14.1580, "lng": -16.0900},
  {"nom": "Pharmacie Dialègne", "adresse": "Village de Dialègne, Kaolack", "telephone": "+221339800010", "lat": 14.2660, "lng": -16.1600},
  {"nom": "Pharmacie Thiaré", "adresse": "Village de Thiaré, Kaolack", "telephone": "+221339800011", "lat": 14.0830, "lng": -16.3000},
  {"nom": "Pharmacie Sibassor Peulh", "adresse": "Sibassor Peulh, Kaolack", "telephone": "+221339800012", "lat": 14.2100, "lng": -16.0700},
  {"nom": "Pharmacie Sam", "adresse": "Quartier Sam, Kaolack", "telephone": "+221339800013", "lat": 14.1520, "lng": -16.0770},
  {"nom": "Pharmacie Passy", "adresse": "Village de Passy, Kaolack", "telephone": "+221339800014", "lat": 14.2500, "lng": -16.4160},
  {"nom": "Pharmacie Latmingué", "adresse": "Latmingué, Kaolack", "telephone": "+221339800015", "lat": 14.2160, "lng": -16.1500},
    ],
    "Fatick": [
       {"nom": "Pharmacie Fatick Centre", "adresse": "Avenue du Commerce, Fatick", "telephone": "+221339600001", "lat": 14.3330, "lng": -16.3830},
  {"nom": "Pharmacie Ndiosmone", "adresse": "Quartier Ndiosmone, Fatick", "telephone": "+221339600002", "lat": 14.3450, "lng": -16.4000},
  {"nom": "Pharmacie Diakhao", "adresse": "Village de Diakhao, Fatick", "telephone": "+221339600003", "lat": 14.3660, "lng": -16.3830},
  {"nom": "Pharmacie Foundiougne", "adresse": "Centre-ville, Foundiougne", "telephone": "+221339600004", "lat": 14.1330, "lng": -16.4660},
  {"nom": "Pharmacie Sokone", "adresse": "Centre Sokone, Fatick", "telephone": "+221339600005", "lat": 13.8830, "lng": -16.3660},
  {"nom": "Pharmacie Diofior", "adresse": "Village de Diofior, Fatick", "telephone": "+221339600006", "lat": 14.1830, "lng": -16.6500},
  {"nom": "Pharmacie Niakhar", "adresse": "Village de Niakhar, Fatick", "telephone": "+221339600007", "lat": 14.5170, "lng": -16.3830},
  {"nom": "Pharmacie Djilor", "adresse": "Village de Djilor, Fatick", "telephone": "+221339600008", "lat": 14.1500, "lng": -16.6830},
  {"nom": "Pharmacie Palmarin", "adresse": "Palmarin, Fatick", "telephone": "+221339600009", "lat": 13.8830, "lng": -16.7500},
  {"nom": "Pharmacie Gossas", "adresse": "Centre-ville, Gossas", "telephone": "+221339600010", "lat": 14.6500, "lng": -16.0660},
  {"nom": "Pharmacie Colobane", "adresse": "Village de Colobane, Fatick", "telephone": "+221339600011", "lat": 14.2160, "lng": -16.4660},
  {"nom": "Pharmacie Tattaguine", "adresse": "Village de Tattaguine, Fatick", "telephone": "+221339600012", "lat": 14.4160, "lng": -16.4330},
  {"nom": "Pharmacie Ndiob", "adresse": "Village de Ndiob, Fatick", "telephone": "+221339600013", "lat": 14.5660, "lng": -16.3830},
  {"nom": "Pharmacie Mbirkilane", "adresse": "Mbirkilane, Fatick", "telephone": "+221339600014", "lat": 14.7160, "lng": -15.9830},
  {"nom": "Pharmacie Keur Samba Gueye", "adresse": "Village de Keur Samba Gueye, Fatick", "telephone": "+221339600015", "lat": 13.9830, "lng": -16.6330},
    ],
    "Sédhiou": [
     {"nom": "Pharmacie Sédhiou Centre", "adresse": "Avenue principale, Sédhiou", "telephone": "+221333910001", "lat": 12.7081, "lng": -15.5569},
  {"nom": "Pharmacie de la Paix", "adresse": "Quartier Escale, Sédhiou", "telephone": "+221333910002", "lat": 12.7085, "lng": -15.5575},
  {"nom": "Pharmacie Ndiarème", "adresse": "Quartier Ndiarème, Sédhiou", "telephone": "+221333910003", "lat": 12.7070, "lng": -15.5540},
  {"nom": "Pharmacie Diannah Malary", "adresse": "Village Diannah Malary, Sédhiou", "telephone": "+221333910004", "lat": 12.7660, "lng": -15.5000},
  {"nom": "Pharmacie Djibabouya", "adresse": "Village Djibabouya, Sédhiou", "telephone": "+221333910005", "lat": 12.7330, "lng": -15.4500},
  {"nom": "Pharmacie Bounkiling", "adresse": "Route principale, Bounkiling", "telephone": "+221333910006", "lat": 12.8000, "lng": -15.2330},
  {"nom": "Pharmacie Marsassoum", "adresse": "Centre-ville, Marsassoum", "telephone": "+221333910007", "lat": 12.8830, "lng": -15.9830},
  {"nom": "Pharmacie Sansamba", "adresse": "Marché central, Sansamba", "telephone": "+221333910008", "lat": 12.6330, "lng": -15.3670},
  {"nom": "Pharmacie Dianah Kounda", "adresse": "Village Dianah Kounda, Sédhiou", "telephone": "+221333910009", "lat": 12.7000, "lng": -15.4330},
  {"nom": "Pharmacie Tanaff", "adresse": "Route principale, Tanaff", "telephone": "+221333910010", "lat": 12.5500, "lng": -15.7330},
  {"nom": "Pharmacie Samine", "adresse": "Quartier Samine, Sédhiou", "telephone": "+221333910011", "lat": 12.7200, "lng": -15.5200},
  {"nom": "Pharmacie Oudoucar", "adresse": "Village Oudoucar, Sédhiou", "telephone": "+221333910012", "lat": 12.6700, "lng": -15.3800},
  {"nom": "Pharmacie Coumba Daga", "adresse": "Quartier Coumba Daga, Sédhiou", "telephone": "+221333910013", "lat": 12.7100, "lng": -15.5700},
  {"nom": "Pharmacie Boghal", "adresse": "Village Boghal, Sédhiou", "telephone": "+221333910014", "lat": 12.6900, "lng": -15.4900},
  {"nom": "Pharmacie Bambali", "adresse": "Village Bambali, Sédhiou", "telephone": "+221333910015", "lat": 12.7000, "lng": -15.6000},
    ],
    "Kolda": [
     {"nom": "Pharmacie Kolda Centre", "adresse": "Avenue de l’Indépendance, Kolda", "telephone": "+221333920001", "lat": 12.8833, "lng": -14.9500},
  {"nom": "Pharmacie Médina Chérif", "adresse": "Quartier Médina Chérif, Kolda", "telephone": "+221333920002", "lat": 12.8900, "lng": -14.9400},
  {"nom": "Pharmacie Fafacourou", "adresse": "Village Fafacourou, Kolda", "telephone": "+221333920003", "lat": 12.9000, "lng": -15.0000},
  {"nom": "Pharmacie Saré Moussa", "adresse": "Village Saré Moussa, Kolda", "telephone": "+221333920004", "lat": 12.8500, "lng": -14.9300},
  {"nom": "Pharmacie Guido", "adresse": "Quartier Guido, Kolda", "telephone": "+221333920005", "lat": 12.8700, "lng": -14.9600},
  {"nom": "Pharmacie Coumba Counda", "adresse": "Quartier Coumba Counda, Kolda", "telephone": "+221333920006", "lat": 12.8800, "lng": -14.9400},
  {"nom": "Pharmacie Médina Yoro Foula", "adresse": "Centre Médina Yoro Foula, Kolda", "telephone": "+221333920007", "lat": 12.6500, "lng": -14.4500},
  {"nom": "Pharmacie Dabo", "adresse": "Village Dabo, Kolda", "telephone": "+221333920008", "lat": 12.7160, "lng": -14.8830},
  {"nom": "Pharmacie Saré Yoba", "adresse": "Village Saré Yoba, Kolda", "telephone": "+221333920009", "lat": 12.8600, "lng": -14.9700},
  {"nom": "Pharmacie Kounkané", "adresse": "Route principale, Kounkané", "telephone": "+221333920010", "lat": 12.5500, "lng": -14.4660},
  {"nom": "Pharmacie Dioulacolon", "adresse": "Village Dioulacolon, Kolda", "telephone": "+221333920011", "lat": 12.8330, "lng": -14.8660},
  {"nom": "Pharmacie Pata", "adresse": "Centre Pata, Kolda", "telephone": "+221333920012", "lat": 12.7330, "lng": -14.5660},
  {"nom": "Pharmacie Mampatim", "adresse": "Village Mampatim, Kolda", "telephone": "+221333920013", "lat": 12.7660, "lng": -14.9660},
  {"nom": "Pharmacie Salikégné", "adresse": "Centre Salikégné, Kolda", "telephone": "+221333920014", "lat": 12.7000, "lng": -14.7500},
  {"nom": "Pharmacie Thiéty", "adresse": "Village Thiéty, Kolda", "telephone": "+221333920015", "lat": 12.8100, "lng": -14.9300},
    ],
    "Ziguinchor": [
      {"nom": "Pharmacie Ziguinchor Centre", "adresse": "Avenue Jean XXIII, Ziguinchor", "telephone": "+221333930001", "lat": 12.5765, "lng": -16.2696},
  {"nom": "Pharmacie Néma", "adresse": "Quartier Néma, Ziguinchor", "telephone": "+221333930002", "lat": 12.5800, "lng": -16.2700},
  {"nom": "Pharmacie Lyndiane", "adresse": "Quartier Lyndiane, Ziguinchor", "telephone": "+221333930003", "lat": 12.5730, "lng": -16.2650},
  {"nom": "Pharmacie Tilène", "adresse": "Quartier Tilène, Ziguinchor", "telephone": "+221333930004", "lat": 12.5780, "lng": -16.2620},
  {"nom": "Pharmacie Boutoute", "adresse": "Quartier Boutoute, Ziguinchor", "telephone": "+221333930005", "lat": 12.5820, "lng": -16.2720},
  {"nom": "Pharmacie Belfort", "adresse": "Quartier Belfort, Ziguinchor", "telephone": "+221333930006", "lat": 12.5840, "lng": -16.2750},
  {"nom": "Pharmacie Grand Dakar", "adresse": "Quartier Grand Dakar, Ziguinchor", "telephone": "+221333930007", "lat": 12.5790, "lng": -16.2680},
  {"nom": "Pharmacie Lyndiane Est", "adresse": "Route de Lyndiane, Ziguinchor", "telephone": "+221333930008", "lat": 12.5740, "lng": -16.2660},
  {"nom": "Pharmacie Tilène Marché", "adresse": "Marché Tilène, Ziguinchor", "telephone": "+221333930009", "lat": 12.5770, "lng": -16.2610},
  {"nom": "Pharmacie Kandé", "adresse": "Quartier Kandé, Ziguinchor", "telephone": "+221333930010", "lat": 12.5850, "lng": -16.2770},
  {"nom": "Pharmacie Hôpital Régional", "adresse": "Près de l’hôpital régional, Ziguinchor", "telephone": "+221333930011", "lat": 12.5810, "lng": -16.2630},
  {"nom": "Pharmacie Santhiaba", "adresse": "Quartier Santhiaba, Ziguinchor", "telephone": "+221333930012", "lat": 12.5750, "lng": -16.2800},
  {"nom": "Pharmacie Djibock", "adresse": "Village Djibock, Ziguinchor", "telephone": "+221333930013", "lat": 12.5500, "lng": -16.3000},
  {"nom": "Pharmacie Badiatte", "adresse": "Quartier Badiatte, Ziguinchor", "telephone": "+221333930014", "lat": 12.5720, "lng": -16.2600},
  {"nom": "Pharmacie Niambalang", "adresse": "Village Niambalang, Ziguinchor", "telephone": "+221333930015", "lat": 12.6000, "lng": -16.3200},
    ],
  };

  late final AnimationController _listIntro;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _listIntro = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() {
    _listIntro.dispose();
    super.dispose();
  }

  // 🌍 Localisation
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (!mounted) return;
    setState(() {
      _userPosition = position;
    });
  }

  double _distance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  String _formatKm(double km) {
    if (km < 1) return "${(km * 1000).toStringAsFixed(0)} m";
    return "${km.toStringAsFixed(km < 10 ? 1 : 0)} km";
  }

  Future<void> _openMap(String query) async {
    final Uri googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _call(String phone) async {
    final tel = Uri.parse("tel:$phone");
    if (await canLaunchUrl(tel)) {
      await launchUrl(tel, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> pharmacies = List.from(pharmaciesParRegion[widget.regionName] ?? []);

    // Tri par distance si localisation ok
    if (_userPosition != null) {
      pharmacies.sort((a, b) {
        final da = _distance(_userPosition!.latitude, _userPosition!.longitude, (a['lat'] ?? 0).toDouble(), (a['lng'] ?? 0).toDouble());
        final db = _distance(_userPosition!.latitude, _userPosition!.longitude, (b['lat'] ?? 0).toDouble(), (b['lng'] ?? 0).toDouble());
        return da.compareTo(db);
      });
    }

    final colorPrimary = const Color(0xFF0E7C24);
    final colorSecondary = const Color(0xFF19A463);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _GlassAppBar(
          title: widget.regionName,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E7C24), Color(0xFF19A463)],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE9F7EF), Color(0xFFD6F5E0)],
                ),
              ),
            ),
          ),
          Positioned(top: -120, left: -80, child: _Blob(size: 200, color: colorPrimary.withOpacity(0.26))),
          Positioned(bottom: -140, right: -60, child: _Blob(size: 260, color: colorSecondary.withOpacity(0.22))),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: _GlassCard(
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: [colorPrimary, colorSecondary]),
                            ),
                            child: const Icon(Icons.local_pharmacy, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pharmacies - ${widget.regionName}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _userPosition == null
                                      ? "Activation de la localisation…"
                                      : "Triées par proximité • ${_userPosition!.latitude.toStringAsFixed(3)}, ${_userPosition!.longitude.toStringAsFixed(3)}",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: pharmacies.isEmpty
                          ? _EmptyState(colorPrimary: colorPrimary, colorSecondary: colorSecondary)
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: pharmacies.length,
                              itemBuilder: (context, index) {
                                final data = pharmacies[index];
                                final lat = (data['lat'] ?? 0).toDouble();
                                final lng = (data['lng'] ?? 0).toDouble();
                                final double? dist = _userPosition == null
                                    ? null
                                    : _distance(_userPosition!.latitude, _userPosition!.longitude, lat, lng);

                                return _PharmacyTile(
                                  index: index,
                                  controller: _listIntro,
                                  name: data['nom'] ?? 'Nom inconnu',
                                  address: data['adresse'] ?? 'Non précisée',
                                  phone: data['telephone'] ?? 'Non précisé',
                                  distanceLabel: dist == null ? null : _formatKm(dist),
                                  onMap: () {
                                    final address = Uri.encodeComponent(data['adresse'] ?? '');
                                    _openMap(address);
                                  },
                                  onCall: () => _call((data['telephone'] ?? '').toString()),
                                  colorPrimary: colorPrimary,
                                  colorSecondary: colorSecondary,
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: GestureDetector(
            onTapDown: (_) {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: [colorPrimary, colorSecondary]),
                boxShadow: [
                  BoxShadow(
                    color: colorPrimary.withOpacity(0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PharmaciesDeGardePage(regionName: widget.regionName),
                    ),
                  );
                },
                icon: const Icon(Icons.local_hospital, color: Colors.white),
                label: const Text(
                  "Voir les pharmacies de garde",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================== Pharmacies de garde ==================
class PharmaciesDeGardePage extends StatelessWidget {
  final String regionName;

  const PharmaciesDeGardePage({Key? key, required this.regionName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const colorPrimary = Color(0xFF0E7C24);
    const colorSecondary = Color(0xFF19A463);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: _GlassAppBar(
          title: "Pharmacies de garde - $regionName",
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorPrimary, colorSecondary],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE9F7EF), Color(0xFFD6F5E0)],
                ),
              ),
            ),
          ),
          Positioned(top: -120, left: -80, child: _Blob(size: 200, color: colorPrimary.withOpacity(0.26))),
          Positioned(bottom: -140, right: -60, child: _Blob(size: 260, color: colorSecondary.withOpacity(0.22))),
          Positioned.fill(
            child: SafeArea(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pharmacies_de_garde')
                    .where('region', isEqualTo: regionName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: _EmptySimple());
                  }

                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.nightlight_round, size: 18, color: Colors.black54),
                                  SizedBox(width: 6),
                                  Text("De garde aujourd’hui", style: TextStyle(fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                data['nom'] ?? 'Nom inconnu',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.place, size: 18, color: Colors.black54),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(data['adresse'] ?? 'Non précisée')),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 18, color: Colors.black54),
                                  const SizedBox(width: 6),
                                  Text(data['telephone'] ?? 'Non précisé'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================== Widgets réutilisables ======================

class _GlassAppBar extends StatelessWidget {
  final String title;
  final Widget? leading;
  final LinearGradient gradient;

  const _GlassAppBar({
    Key? key,
    required this.title,
    this.leading,
    required this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: leading,
          title: Row(
            children: [
              const Icon(Icons.local_pharmacy, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({Key? key, required this.size, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 120, spreadRadius: 40),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
            boxShadow: [
              BoxShadow(color: Colors.green.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 10)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ================== Tile Pharmacie ==================
class _PharmacyTile extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final String name;
  final String address;
  final String phone;
  final String? distanceLabel;
  final VoidCallback onMap;
  final VoidCallback onCall;
  final Color colorPrimary;
  final Color colorSecondary;

  const _PharmacyTile({
    Key? key,
    required this.index,
    required this.controller,
    required this.name,
    required this.address,
    required this.phone,
    required this.distanceLabel,
    required this.onMap,
    required this.onCall,
    required this.colorPrimary,
    required this.colorSecondary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final intervalStart = (0.05 * index).clamp(0.0, 0.8);
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(intervalStart, 1, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(animation),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Stack(
            children: [
              Positioned.fill(
                top: 10,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: colorPrimary.withOpacity(0.10),
                          blurRadius: 28,
                          spreadRadius: 2,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        ),
                        if (distanceLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(colors: [colorPrimary, colorSecondary]),
                            ),
                            child: Text(distanceLabel!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.place, size: 18, color: Colors.black54),
                        ),
                        const SizedBox(width: 6),
                        Expanded(child: Text(address)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(phone),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: "Appeler",
                            icon: Icons.call,
                            onTap: onCall,
                            gradient: LinearGradient(colors: [colorPrimary, colorSecondary]),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionButton(
                            label: "Google Maps",
                            icon: Icons.map,
                            onTap: onMap,
                            gradient: LinearGradient(colors: [colorSecondary, colorPrimary]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== Bouton action ==================
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Gradient gradient;

  const _ActionButton({Key? key, required this.label, required this.icon, required this.onTap, required this.gradient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(14)),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        icon: const Icon(Icons.chevron_right, color: Colors.transparent),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ================== États vides ==================
class _EmptyState extends StatelessWidget {
  final Color colorPrimary;
  final Color colorSecondary;
  const _EmptyState({Key? key, required this.colorPrimary, required this.colorSecondary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.medical_services_rounded, size: 42, color: Colors.black45),
            SizedBox(height: 10),
            Text("Aucune pharmacie listée pour cette région", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _EmptySimple extends StatelessWidget {
  const _EmptySimple({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Aucune pharmacie de garde trouvée"),
    );
  }
}
