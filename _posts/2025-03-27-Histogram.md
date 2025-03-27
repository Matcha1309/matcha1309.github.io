---
title: "Hraní si s histogramy"

- "/assets/img/histogramy/hist02.png"  
---
<!--begin_excerpt-->
Krátká vsuvka - předminulý týden jsme si ve škole hráli s barevnými histogramy.
Úkol byl jasný, pro několik snímků z videa udělat 3D histogram barev, v prostoru RGB,
přepočtený tak, aby byly hodnoty v každé ose přepočítány místo z 0-255 na 0-3.

![h1](/assets/img/histogramy/hist01.png)
<!--end_excerpt-->
Tady jedna ilustrace z videa s oranžovou rybou, co jsem udělala už ve škole. Ale na videu s rybou se toho moc nemění.

Proč neudělat pěkné video side-by-side s původním? Proč si celý histogram nechat zastínit pozadím?
Ve výsledku, na který se můžete podívat níže, je video, které jsem stáhla z youtube (kanál [@PetrGanaj](https://www.youtube.com/@PetrGanaj)),
ke kterému jsou "přilepené" histogramy (spočítaný je eden histogram na šest snímků původního videa,
tedy čtyři za sekundu), naanimované tak, aby běžely synchronizovaně. Histogram ignoruje černou (`#000000`),
aby odfiltroval pozadí - čistě černá se totiž v kvetoucím tulipánu objevuje naprosto minimálně.
Velikosti kroužků v histogramu odpovídají poměrnému zastoupení daného "chlívečku", do kterého barva spadne,
barva je dotyčného "chlívečku" a střed kolečka je umístěn uprostřed.
Počítání histogramů bylo realizováno v pythonu, pro rozdělení videa na framy a slepení původních
framů se zpracovanými histogramy byl použit [ffmpeg](https://ffmpeg.org/).

Výsledek můžete shlédnout zde: [Video](https://youtu.be/YmgYflAUBVc), pokud by vás zajímal kód,
můžete ho vidět [tady](https://matcha1309.github.io/histogram) TODO! (odkaz nefunguje).

![h2](/assets/img/histogramy/hist02.jpg)

## A jak se to vlastně dělá? 

{% details FFMPEG - rozdělení na framy %}
```bash
#!/bin/sh
rm -rf in
mkdir in
ffmpeg -i input.mp4 -ss 0:03 -t 0:26 in/%05d.png
```
{% enddetails %}

{% details PYTHON - zpracování histogramů %}
```python
import numpy as np
import matplotlib.pyplot as plt
import math
from PIL import Image

# protože se obrázky ve velkém rozlišení počítaly pomalu, tohle je zmenší, což nám ale moc nevadíí
def resize_image(img, max_size=200):
    w, h = img.size
    scale = max_size / max(w, h)                    # kolik "procent" ? 
    new_size = (int(w * scale), int(h * scale))  
    return img.resize(new_size, Image.LANCZOS)  # Resize using high-quality filter      https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.windows.lanczos.html

# tohle vykreslí vlastní histogram
def drawHistogram3D(points, sizes, colors):
    fig = plt.figure(figsize=(5, 5))
    ax = fig.add_subplot(111, projection='3d')
    ax.scatter(points[:, 0], points[:, 1], points[:, 2], s=sizes, c=colors, alpha=1)  
    ax.set_xlabel("R")
    ax.set_ylabel("G")
    ax.set_zlabel("B")
    return fig  

q_levels = 4                # "měříkto" histogramu ("na kolik binů"?)
step = 256 / q_levels
histogramRGB = np.zeros((q_levels, q_levels, q_levels))  
j = 0

while j < 780:                                              # měnit si to na počet framů v in (na které se rozsekalo video)
    for i in range(1, 6):                                       # pro kazdy obrázek ze skpiny po 6, z těch bude histogram
        image_path = f"in/{i+j:05d}.png" 
        img = Image.open(image_path)
        img = resize_image(img, max_size=200)           # zmenšit, jinak je to pomalý
        img_array = np.array(img)
        height, width, _ = img_array.shape
                                            
        for y in range(height):                             # pro každý pixel v obrázku, na ktrý právě koukáme
            for x in range(width):
                r, g, b = img_array[y, x]
                r_batch = math.floor(r / step)
                g_batch = math.floor(g / step)
                b_batch = math.floor(b / step)
                if r_batch != 0 and g_batch != 0 and b_batch != 0:      # jen pokud ma obrázek črné pozadí, tohle ho ignoruje, lze kompenzovat jakékoli    
                    histogramRGB[r_batch, g_batch, b_batch] += 1        # pro každý px spočítá, kam spadne a tomu zvýší value

    points = []
    sizes = []
    colors = []

    for r in range(q_levels):
        for g in range(q_levels):
            for b in range(q_levels):  # přes všchny barevné kombinace
                count = histogramRGB[r, g, b]
                if count > 0:           # pokud tam ta barva je, ignoruj nezastoupené 
                    points.append((r, g, b))
                    sizes.append((count / np.max(histogramRGB)) * 4000)  # rescale, protože kfyž to není znormované, vypadá hnusně
                    colors.append('#{:02x}{:02x}{:02x}'.format(int((r + 0.5) * step), int((g + 0.5) * step), int((b + 0.5) * step)))        # zprostředka kroku, tedy velikosti krychliky

    points = np.array(points)
    
    fig = drawHistogram3D(points, sizes, colors)
    plt_filename = f"out/plt{(j//6 + 1):03d}.png"          # uloží jako plt001.png atd...
    plt.savefig(plt_filename)
    plt.close(fig)

    j = j + 6
```
{% enddetails %}

{% details FFMPEG - opětovné slepení a přidání histogramů %}
```bash
#!/bin/sh
rm -f output.mp4
ffmpeg -r 24 -i in/%05d.png -r 4 -i out/plt%03d.png -filter_complex '[1]scale=h=738:w=-1[1s];[0][1s]hstack' -c:v libx264 output.mp4
```
{% enddetails %}

Další obrázky z mojí dílny si můžete prohlédnout v [Galerii](/galerie/).
