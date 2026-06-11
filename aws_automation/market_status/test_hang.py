import os
import time
import re
import undetected_chromedriver as uc
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager

print("Setting up")
options = uc.ChromeOptions()
options.add_argument('--headless=new')
driver_path = ChromeDriverManager().install()
driver = uc.Chrome(options=options, driver_executable_path=driver_path, version_main=144)

print("Getting URL")
driver.get("https://www.egx.com.eg/ar/homepage.aspx")

print("Sleeping 15")
time.sleep(15)

print("Trying Market Cap")
raw_text = ""
for i in range(10):
    try:
        print(f"Loop {i}")
        cap_element = driver.find_element(By.ID, "ctl00_C_HomeMarketsummary2_lclTotalMC")
        raw_text = (cap_element.get_attribute("textContent") or cap_element.text).strip()
        if raw_text:
            break
    except Exception as e:
        pass
    time.sleep(1)

print(f"Fallback, raw_text={raw_text}")
if not raw_text:
    mc_labels = driver.find_elements(By.XPATH, "//*[contains(text(), 'رأس المال السوق')]")
    print(f"Found {len(mc_labels)} labels")
    for label in mc_labels:
        parent_text = label.find_element(By.XPATH, "..").get_attribute("textContent")
        print("Parent text:", parent_text)
        parts = parent_text.split()
        numbers = [p for p in parts if re.match(r'^[\d,]+(\.\d+)?$', p)]
        if numbers:
            raw_text = numbers[-1]
            break

print("Final:", raw_text)
driver.quit()
