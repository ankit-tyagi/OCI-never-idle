import os
import time
from googlesearch import search
import requests
from PIL import Image
from io import BytesIO
import shutil
import time

def log(message):
    with open("trending_topics.log", "a") as log_file:
        log_file.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - {message}\n")
        print(message)

def get_trending_topics():
    query = "top trending topics"
    trending_topics = []

    for result in search(query, num_results=10):
        trending_topics.append(result.title)

    return trending_topics[:5]

def download_images(topic, max_size=2 * 1024 * 1024, num_images=5):
    query = f"{topic} site:unsplash.com"
    image_urls = []

    for result in search(query, num_results=num_images * 2):
        if len(image_urls) >= num_images:
            break
        if result.url.endswith(".jpg"):
            image_urls.append(result.url)
        time.sleep(5)

    downloaded_images = []
    for url in image_urls:
        try:
            response = requests.get(url)
            img = Image.open(BytesIO(response.content))
            time.sleep(5)  # Add 2-second delay after each request

            if len(response.content) <= max_size:
                downloaded_images.append(img)
                log(f"Downloaded image for {topic} from {url}")

        except Exception as e:
            log(f"Error downloading image from {url}: {e}")

    return downloaded_images

def main():
    log("Starting trending topics search")
    topics = get_trending_topics()

    for topic in topics:
        log(f"Processing topic: {topic}")
        images = download_images(topic)
        time.sleep(1)

        image_folder = f"images/{topic}"
        os.makedirs(image_folder, exist_ok=True)

        for i, img in enumerate(images):
            img_path = os.path.join(image_folder, f"{i}.jpg")
            img.save(img_path)

        for i, img in enumerate(images):
            img_path = os.path.join(image_folder, f"{i}.jpg")
            os.remove(img_path)

        shutil.rmtree(image_folder)

    log("Finished trending topics search")

if __name__ == "__main__":
    main()
