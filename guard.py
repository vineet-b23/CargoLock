import time
from bridge import ask_the_ai

def monitor_blockchain():
    print("Watching the blockchain for events...")
    
    # SIMULATION: In a real hack, you'd use web3.py to get real events
    while True:
        # Pretend we just caught a new event from a Smart Contract
        new_event_data = {
            "from": "0xAbc123...",
            "value": "1000 ETH",
            "gas_price": "0",
            "contract_type": "DeFi Lending"
        }
        
        # Turn data into a sentence for the AI
        sentence = f"A user is trying to move {new_event_data['value']} in a {new_event_data['contract_type']} contract with {new_event_data['gas_price']} gas."
        
        # Ask the Brain
        prediction = ask_the_ai(sentence)
        
        print(f"ALERT: New Activity Detected!")
        print(f"AI Verdict: {prediction['top_prediction']} ({prediction['confidence']})")
        
        # Pause for 10 seconds (Simulating waiting for the next block)
        time.sleep(10)

if __name__ == "__main__":
    monitor_blockchain()