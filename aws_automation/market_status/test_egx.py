import undetected_chromedriver as uc
from selenium.webdriver.common.by import By
import time
from webdriver_manager.chrome import ChromeDriverManager

options = uc.ChromeOptions()
options.add_argument('--headless=new')
driver_path = ChromeDriverManager().install()
driver = uc.Chrome(options=options, driver_executable_path=driver_path, version_main=144)
driver.get("https://www.egx.com.eg/ar/homepage.aspx")
time.sleep(15)

source = driver.page_source
with open('page.html', 'w', encoding='utf-8') as f:
    f.write(source)

print("Saved page source")
try:
    print("Trying original ID:", driver.find_element(By.ID, "ctl00_C_HomeMarketsummary2_lclTotalMC").text)
except Exception as e:
    print("ID failed:", e)

driver.quit()
