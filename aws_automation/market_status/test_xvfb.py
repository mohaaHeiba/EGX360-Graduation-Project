import undetected_chromedriver as uc
from selenium.webdriver.common.by import By
import time
from webdriver_manager.chrome import ChromeDriverManager

options = uc.ChromeOptions()
# NOT headless
driver_path = ChromeDriverManager().install()
driver = uc.Chrome(options=options, driver_executable_path=driver_path, version_main=144)
driver.get("https://www.egx.com.eg/ar/homepage.aspx")
print("Sleeping for 20s to bypass F5...")
time.sleep(20)

with open('page_xvfb.html', 'w', encoding='utf-8') as f:
    f.write(driver.page_source)

driver.quit()
