<!DOCTYPE html>
<html>
<head>
    <title>Home Page</title>
    <link rel="stylesheet" href="/static/style.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            margin-top: 40px;
            background-color: #f4f4f9;
        }
        nav a {
            margin: 0 10px;
            text-decoration: none;
            color: #333;
            font-weight: bold;
        }
        .stat-box {
            font-size: 24px;
            margin: 10px;
            font-weight: bold;
        }
        #counter { color: #007BFF; font-size: 48px; }
        #timer { color: #DC3545; }
        #message {
            font-size: 28px;
            font-weight: bold;
            margin: 20px 0;
            min-height: 40px;
        }
        button {
            padding: 15px 30px;
            font-size: 20px;
            cursor: pointer;
            background-color: #28a745;
            color: white;
            border: none;
            border-radius: 5px;
            font-weight: bold;
        }
        button:hover { background-color: #218838; }
        button:disabled {
            background-color: #6c757d;
            cursor: not-allowed;
        }
        .gif-container img {
            margin-top: 20px;
            max-width: 300px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }
    </style>
</head>
<body>
    <nav>
        <a href="/">Home</a>
        <a href="/about">About</a>
        <a href="/contact">Contact</a>
    </nav>
    
    <img src="static/sukuna.gif" alt="My animated GIF" width="300">
    <img src="static/bruh.gif" alt="My animated GIF" width="300">
    <img src="static/toji.gif" alt="My animated GIF" width="300">
    
    <h1>Click to land 10 consecutive black flashes in order to save Gojo </h1>

    <!-- FIXED: Removed the duplicate id="counter" from here to prevent JS confusion -->
    <div class="stat-box">Clicks: <span id="counter">0</span> / 10</div>
    <div class="stat-box">Time Left: <span id="timer">1.0</span>s</div>
    
    <div id="message">Click the button to start!</div>
    
    <button id="clickBtn">CLICK ME!</button>
    
    <div class="gif-container" id="gifDisplay"></div>

    <script>
        // Game variables
        let count = 0;
        let timeLeft = 1.0;
        let timerId = null;
        let gameStarted = false;
        let gameActive = true;

        // Target settings
        const TARGET_CLICKS = 10;

        // DOM elements
        const counterDisplay = document.getElementById('counter');
        const timerDisplay = document.getElementById('timer');
        const messageDisplay = document.getElementById('message');
        const button = document.getElementById('clickBtn');
        const gifDisplay = document.getElementById('gifDisplay');

        // Main button click logic
        button.addEventListener('click', () => {
            if (!gameActive) return;

            // Start timer on the very first click
            if (!gameStarted) {
                startGame();
            }

            // Increment count
            count++;
            counterDisplay.textContent = count;

            // Check if player won early
            if (count >= TARGET_CLICKS) {
                endGame(true);
            }
        });

        function startGame() {
            gameStarted = true;
            messageDisplay.textContent = "Keep clicking!";
            
            // Run timer interval every 100ms for smooth decimal countdown
            timerId = setInterval(() => {
                timeLeft -= 0.1;
                
                // Fix JavaScript decimal rounding bugs
                timerDisplay.textContent = timeLeft.toFixed(1);

                if (timeLeft <= 0) {
                    timerDisplay.textContent = "0.0";
                    endGame(false);
                }
            }, 100);
        }

        function endGame(isWin) {
            clearInterval(timerId);
            gameActive = false;
            button.disabled = true;

            if (isWin) {
                messageDisplay.textContent = "🎉 Yippie you saved Gojo! 🎉";
                messageDisplay.style.color = "#28a745";
                // FIXED: Changed template literal to a straight string path
                gifDisplay.innerHTML = '<img src="static/won.jpg" alt="Winner Celebration">';
            } else {
                messageDisplay.textContent = "❌ Aww mayn Gojo is dead... ❌";
                messageDisplay.style.color = "#DC3545";
                // FIXED: Changed template literal to a straight string path
                gifDisplay.innerHTML = '<img src="static/dead.gif" alt="Game Over Sad Face">';
            }
        }
    </script>
</body>
</html>