
def parse_response(stdout, action_map):
    if not stdout:
        return None
    
    # Split by lines and take the last non-empty line
    lines = [line.strip() for line in stdout.split('\n') if line.strip()]
    if not lines:
        return None
    
    response = lines[-1]
    print(f"DEBUG: Raw extracted response: '{response}'")
    
    # Try case-insensitive match in action_map
    # First, check titles (keys in action_map)
    for title, action_id in action_map.items():
        if response.lower() == title.lower():
            print(f"DEBUG: Matched title '{title}' -> '{action_id}'")
            return action_id
        if response.lower() == action_id.lower():
            print(f"DEBUG: Matched action_id directly -> '{action_id}'")
            return action_id
            
    return response

# Test Case 1: Standard success
action_map = {"I Did!": "Hike_Off", "Remind Me In 15": "15_Min_Hike"}
stdout1 = "I Did!\n"
assert parse_response(stdout1, action_map) == "Hike_Off"

# Test Case 2: SSH Banner
stdout2 = "Last login: Sun Jan 25 10:00:00 2026 from 192.168.1.50\r\nI Did!\r\n"
assert parse_response(stdout2, action_map) == "Hike_Off"

# Test Case 3: Case insensitivity
stdout3 = "i did!\n"
assert parse_response(stdout3, action_map) == "Hike_Off"

# Test Case 4: Extra whitespace
stdout4 = "   Remind Me In 15   \n"
assert parse_response(stdout4, action_map) == "15_Min_Hike"

# Test Case 5: Action ID directly
stdout5 = "Hike_Off\n"
assert parse_response(stdout5, action_map) == "Hike_Off"

print("All tests passed!")
