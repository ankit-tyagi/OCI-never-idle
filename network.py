import requests
from bs4 import BeautifulSoup
import os
import time
import logging

# Configure logging
logging.basicConfig(filename='scraping.log', level=logging.INFO, format='%(asctime)s - %(message)s')

def clear_directory(directory):
    for file in os.listdir(directory):
        file_path = os.path.join(directory, file)
        try:
            if os.path.isfile(file_path):
                os.unlink(file_path)
        except Exception as e:
            logging.error(f"Error while deleting file {file_path}: {e}")

def scrape_images_from_url(url):
    try:
        response = requests.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')
        images = soup.find_all('img')

        if not os.path.exists('scraped_images'):
            os.mkdir('scraped_images')
        else:
            clear_directory('scraped_images')

        downloaded_size = 0
        for index, image in enumerate(images):
            img_url = image.get('src')
            if not img_url.startswith('http'):
                img_url = url + '/' + img_url

            img_data = requests.get(img_url).content
            downloaded_size += len(img_data)
            file_name = os.path.join('scraped_images', f"{url.replace('https://', '').replace('/', '_')}_{index}.jpg")
            with open(file_name, 'wb') as f:
                f.write(img_data)
                logging.info(f"Downloaded image from {url}: {file_name}")

        return downloaded_size
    except Exception as e:
        logging.error(f"Error while downloading images from {url}: {e}")
        return 0


if __name__ == "__main__":
    websites = [
        'https://www.amazon.com',
        'https://www.alibaba.com',
        'https://www.jd.com',
        'https://www.ebay.com',
        'https://www.walmart.com',
        'https://world.taobao.com',
        'https://global.rakuten.com',
        'https://www.zalando.com',
        'https://www.asos.com',
        'https://www.flipkart.com',
        'https://www.etsy.com',
        'https://www.mercadolibre.com',
        'https://www.shopify.com',
        'https://www.bestbuy.com',
        'https://www.target.com',
        'https://www.costco.com',
        'https://www.nordstrom.com',
        'https://www.macys.com',
        'https://www.homedepot.com',
        'https://www.wayfair.com',
        'https://www.sephora.com',
        'https://www.chewy.com',
        'https://www.instacart.com',
        'https://deliveroo.com',
        'https://www.ubereats.com',
        'https://www.groupon.com',
        'https://www.iherb.com',
        'https://www.net-a-porter.com',
        'https://www.bigbasket.com',
        'https://www.myntra.com',
        'https://www.lazada.com',
        'https://www.carrefour.com',
        'https://www.ssense.com',
        'https://www.woolworths.com.au',
        'https://www.ozon.ru',
        'https://www.pinduoduo.com',
        'https://www.yoox.com',
        'https://www.cultbeauty.com',
        'https://www.mercari.com',
        'https://www.thehutgroup.com',
        'https://www.uniqlo.com',
        'https://shopee.com',
        'https://www.ulta.com',
        'https://www.cvs.com',
        'https://www.boots.com',
        'https://www.dsw.com',
        'https://www.footlocker.com',
        'https://www.nike.com',
        'https://www.adidas.com',
        'https://www.footaction.com',
        'https://www.newegg.com',
        'https://www.gilt.com',
        'https://www.jcpenney.com',
        'https://www.kohls.com',
        'https://www.sears.com',
        'https://www.tesco.com',
        'https://waymo.com',
        'https://www.target.com.au',
        'https://www.woolworths.com.au',
        'https://www.aldi.com',
        'https://www.lidl.com',
        'https://www.tesco.ie',
        'https://www.sainsburys.co.uk',
        'https://www.waitrose.com',
        'https://www.ocado.com',
        'https://www.fnac.com',
        'https://www.decathlon.com',
        'https://www.zara.com',
        'https://www.hm.com',
        'https://shop.mango.com',
        'https://www.kmart.com',
        'https://www.officedepot.com',
        'https://www.staples.com',
        'https://www.booktopia.com.au',
        'https://www.bookdepository.com',
        'https://www.thebookpeople.co.uk',
        'https://www.barnesandnoble.com',
        'https://www.waterstones.com',
        'https://www.gamestop.com',
        'https://www.cdprojektred.com',
        'https://store.steampowered.com',
        'https://www.gog.com',
        'https://www.gamefly.com',
        'https://www.gamespot.com',
        'https://store.playstation.com',
        'https://www.xbox.com',
        'https://www.origin.com',
        'https://www.ubisoft.com',
        'https://www.epicgames.com',
        'https://www.humblebundle.com',
        'https://www.greenmangaming.com',
        'https://www.fanatical.com',
        'https://www.gamebillet.com',
        'https://www.kinguin.net',
        'https://www.cdkeys.com'
        # Add more URLs here
    ]

    start_time = time.time()
    total_downloaded_size = 0
    for website in websites:
        total_downloaded_size += scrape_images_from_url(website)

    end_time = time.time()
    elapsed_time = end_time - start_time
    total_downloaded_size_mb = total_downloaded_size / (1024 * 1024)
    
    logging.info(f"Completed scraping {len(websites)} websites in {elapsed_time:.2f} seconds")
    logging.info(f"Total downloaded size: {total_downloaded_size_mb:.2f} MB")
