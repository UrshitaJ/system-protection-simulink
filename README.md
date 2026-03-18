# Overcurrent and Undervoltage Protection Relay (Simulink)

## 📌 Overview

This project implements a digital protection relay in Simulink for detecting **overcurrent** and **undervoltage** faults in a power system. It also indicates and logs timestamps of when the power factor dips below a given threshhold. The system continuously monitors voltage and current signals, computes RMS values, and triggers a relay trip when abnormal conditions are detected.

The model also includes **fault logging with timestamps** and a visual interface for real-time monitoring.

---

## ⚙️ Features

* Overcurrent fault detection
* Undervoltage fault detection
* Integrated power factor calculation and low PF detection 
* RMS-based measurement using Moving RMS blocks
* Relay trip logic with fault indication
* Fault event logging with time stamps
* Real-time visualization using scopes and indicators

---

## 🧠 Working Principle

1. Input voltage and current signals are fed into the system
2. RMS values are computed using a moving window
3. Threshold-based logic detects:

   * Overcurrent (Irms > set limit)
   * Undervoltage (Vrms < set limit)
4. If a fault is detected:

   * Relay state changes (trip signal activated)
   * Fault type is identified and logged with time
5. When conditions return to normal:

   * Relay resets
   * Fault cleared event is logged

---

## 🛠️ Tools & Technologies

* MATLAB
* Simulink

---

## 📊 Key Parameters

* Overcurrent Threshold: 8 A
* Undervoltage Threshold: 180 V
* RMS Window Size: 0.02 s

---

## 📷 Model Preview

<img width="1298" height="817" alt="image" src="https://github.com/user-attachments/assets/017b1379-3b83-4c94-a2eb-cf97f263db6d" />
<img width="1046" height="662" alt="image" src="https://github.com/user-attachments/assets/66fe9386-7787-4730-a5e8-073818712592" />


---

## 🚀 How to Run

1. Open the `.slx` file in Simulink
2. Run the simulation
3. Observe:

   * Relay state indicator
   * Fault signals
   * Logged outputs in MATLAB console

---

## 💡 Learning Outcomes

* Implementation of protection logic in Simulink
* Understanding RMS-based fault detection
* Event-based logging using MATLAB Function blocks
* Simulation of real-time relay behavior

---

## 🔮 Future Improvements

* Add overvoltage and short-circuit protection
* Introduce time-delay relay characteristics
* Integrate hardware (microcontroller-based relay)
* Expand to three-phase system

---

## 📎 Urshita Jaiswal

Your Name
