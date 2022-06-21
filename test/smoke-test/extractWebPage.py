import time
from selenium import webdriver

### Use Selenium with Chromium in Headless mode (no GUI)
options = webdriver.ChromeOptions()
options.add_argument("--headless")
options.add_argument("--disable-extensions")
options.add_argument("--disable-dev-shm-usage")
options.add_argument("--no-sandbox")
options.add_experimental_option("prefs",{"download.default_directory":"/databricks/driver"})
driver = webdriver.Chrome(options=options)

### Get website page
URL = "http://localhost:3000"
driver.get(URL)

### Wait for table to be fulfilled before exporting page to .html
time.sleep(10)
with open('page.html', 'w') as f:
    f.write(driver.page_source)

driver.quit()
