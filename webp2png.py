import os
from PIL import Image

def convertir_webp_a_png(ruta_base):
    for carpeta_actual, subcarpetas, archivos in os.walk(ruta_base):
        for archivo in archivos:
            if archivo.lower().endswith('.webp'):
                ruta_completa = os.path.join(carpeta_actual, archivo)
                ruta_png = os.path.splitext(ruta_completa)[0] + '.png'

                try:
                    with Image.open(ruta_completa) as img:
                        img.save(ruta_png, 'PNG')
                    os.remove(ruta_completa)
                    print(f'✅ Convertido y eliminado: {ruta_completa}')
                except Exception as e:
                    print(f'❌ Error con {ruta_completa}: {e}')

# Reemplaza esto con la ruta que quieras escanear
ruta_objetivo = ./"
convertir_webp_a_png(ruta_objetivo)
