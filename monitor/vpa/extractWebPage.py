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
URL = "http://localhost:8080/dashboard"
driver.get(URL)

### Wait for website to be fully loaded before exporting page to .html
time.sleep(10)
with open('report.html', 'w') as f:
    f.write(driver.page_source)

driver.quit()
