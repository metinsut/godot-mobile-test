# godot-test-mobile-1

Godot dosya yapisini ogrenmek icin hazirlanmis cok kucuk bir mobil prototip.

Ekranin ortasinda bir savasci var. Ok tuslariyla etrafta yurur; alt kisimdaki iki buton savascinin kilic sallama ve kalkan kaldirma animasyonlarini tetikler.

## Dosya yapisi

- `project.godot`: Proje ayarlari ve ana sahne referansi.
- `scenes/main.tscn`: Oyun ekrani, arka plan, savasci instance'i ve UI butonlari.
- `scenes/warrior.tscn`: Savascinin parcalari, kilic, kalkan ve govde node'lari.
- `scripts/main.gd`: Butonlara basilinca warrior metodlarini cagirir.
- `scripts/warrior.gd`: Ok tusu hareketini, yurumeyi, `attack()` ve `defend()` animasyonlarini yonetir.
- `tests/test_project_structure.gd`: Godot CLI varsa headless smoke test.
- `tests/validate_project_structure.sh`: Godot CLI yoksa calistirilabilecek yerel smoke test.

## Test

Bu ortamda Godot CLI kurulu degilse:

```bash
bash tests/validate_project_structure.sh
```

Godot CLI kuruluysa:

```bash
godot --headless --script tests/test_project_structure.gd
```
