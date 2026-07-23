<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pop the Lock</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            text-align: center;
            background: #121212;
            color: white;
            margin: 0;
            padding: 20px;
            user-select: none;
            -webkit-user-select: none;
        }
        .setup-panel {
            background: #1e1e1e;
            padding: 15px;
            border-radius: 8px;
            max-width: 450px;
            margin: 0 auto 20px auto;
            border: 1px solid #333;
        }
        input[type="text"] {
            width: 75%;
            padding: 10px;
            border-radius: 4px;
            border: 1px solid #444;
            background: #2a2a2a;
            color: white;
            font-size: 14px;
        }
        .stats {
            font-size: 28px;
            margin-bottom: 5px;
            font-weight: bold;
            color: #ffd54f;
        }
        .highscore {
            font-size: 18px;
            color: #888;
            margin-bottom: 15px;
        }
        #gameCanvas {
            background: #121212;
            display: block;
            margin: 0 auto;
            cursor: pointer;
        }
        .instructions {
            margin-top: 15px;
            color: #666;
            font-size: 14px;
        }
        button {
            background: #ff5722;
            color: white;
            border: none;
            padding: 12px 28px;
            font-size: 18px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            transition: background 0.2s;
            margin-bottom: 10px;
        }
        button:hover {
            background: #e64a19;
        }
        button:focus {
            outline: none;
        }
    </style>
</head>
<body>

    <h1>Pop the Lock</h1>
    
    <div class="setup-panel">
        <label for="musicUrl"><strong>Music Stream URL:</strong> </label><br><br>
        <input type="text" id="musicUrl" value="https://soundhelix.com">
    </div>

    <div class="stats">Streak: <span id="score">0</span></div>
    <div class="highscore">Best Streak: <span id="bestScore">0</span></div>
    
    <button id="start-btn" onclick="startGame()">Start Game</button>
    
    <canvas id="gameCanvas" width="400" height="400"></canvas>
    
    <div class="instructions">Press <strong>SPACEBAR</strong> or <strong>CLICK the screen</strong> right when the white dot hits the red circle!</div>

    <script>
        const canvas = document.getElementById('gameCanvas');
        const ctx = canvas.getContext('2d');
        const scoreBoard = document.getElementById('score');
        const bestBoard = document.getElementById('bestScore');
        const musicInput = document.getElementById('musicUrl');
        const startBtn = document.getElementById('start-btn');

        const cx = 200;
        const cy = 250;
        const radius = 80;

        let isPlaying = false;
        let score = 0;
        let highscore = 0;
        let bgMusic = null;

        let currentAngle = -90; 
        let targetAngle = 0;
        let moveClockwise = true;
        let speed = 2.2; 
        
        const hitTolerance = 14; 
        let frameId = null;
        let totalDegreesMovedSinceTarget = 0;

        function init() {
            renderLock(currentAngle, targetAngle, false);
        }

        function startGame() {
            if (isPlaying) return;

            if (bgMusic) {
                bgMusic.pause();
                bgMusic = null;
            }
            bgMusic = new Audio(musicInput.value);
            bgMusic.loop = true;
            bgMusic.crossOrigin = "anonymous";
            bgMusic.play().catch(err => console.log(err));

            score = 0;
            scoreBoard.textContent = score;
            currentAngle = -90; 
            moveClockwise = true;
            speed = 2.2;
            isPlaying = true;
            startBtn.disabled = true;
            startBtn.style.opacity = 0.3;

            generateNewTarget();
            
            totalDegreesMovedSinceTarget = -45; 

            if (frameId) cancelAnimationFrame(frameId);
            gameLoop();
        }

        function generateNewTarget() {
            let distance = Math.floor(Math.random() * 100) + 60;
            
            if (moveClockwise) {
                targetAngle = currentAngle + distance;
            } else {
                targetAngle = currentAngle - distance;
            }
            
            targetAngle = normalizeDegrees(targetAngle);
            totalDegreesMovedSinceTarget = 0; 
        }

        function normalizeDegrees(deg) {
            deg = deg % 360;
            if (deg > 180) deg -= 360;
            if (deg <= -180) deg += 360;
            return deg;
        }

        function checkPlayerTap() {
            if (!isPlaying) return;

            let diff = Math.abs(normalizeDegrees(currentAngle - targetAngle));

            if (diff <= hitTolerance) {
                score++;
                scoreBoard.textContent = score;
                if (score > highscore) {
                    highscore = score;
                    bestBoard.textContent = highscore;
                }
                
                moveClockwise = !moveClockwise;
                speed = Math.min(4.5, 2.2 + (score * 0.12)); 
                
                generateNewTarget();
            } else {
                endGame();
            }
        }

        function endGame() {
            isPlaying = false;
            startBtn.disabled = false;
            startBtn.style.opacity = 1;
            if (bgMusic) {
                bgMusic.pause();
            }
            cancelAnimationFrame(frameId);
            alert(`Game Over! Missed target. Final Streak: ${score}`);
            renderLock(currentAngle, targetAngle, false);
        }

        function gameLoop() {
            if (!isPlaying) return;

            let step = speed;
            if (moveClockwise) {
                currentAngle += step;
            } else {
                currentAngle -= step;
            }
            
            currentAngle = normalizeDegrees(currentAngle);
            totalDegreesMovedSinceTarget += step;

            let diff = Math.abs(normalizeDegrees(currentAngle - targetAngle));
            
            if (totalDegreesMovedSinceTarget > 30) {
                let checkingBuffer = hitTolerance + 2;
                
                if (moveClockwise) {
                    let relativeDiff = normalizeDegrees(currentAngle - targetAngle);
                    if (relativeDiff > checkingBuffer && relativeDiff < 90) {
                        endGame();
                        return;
                    }
                } else {
                    let relativeDiff = normalizeDegrees(targetAngle - currentAngle);
                    if (relativeDiff > checkingBuffer && relativeDiff < 90) {
                        endGame();
                        return;
                    }
                }
            }

            renderLock(currentAngle, targetAngle, true);
            frameId = requestAnimationFrame(gameLoop);
        }

        function renderLock(lineDeg, dotDeg, drawTargetDot) {
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            ctx.lineWidth = 14;
            ctx.strokeStyle = '#555';
            ctx.lineCap = 'round';
            ctx.beginPath();
            ctx.arc(cx, cy - 35, 45, Math.PI, 0);
            ctx.stroke();

            ctx.lineWidth = 20;
            ctx.strokeStyle = '#ffd54f';
            ctx.beginPath();
            ctx.arc(cx, cy, radius, 0, Math.PI * 2);
            ctx.stroke();

            ctx.fillStyle = '#1e1e1e';
            ctx.beginPath();
            ctx.arc(cx, cy, radius - 10, 0, Math.PI * 2);
            ctx.fill();

            let radConversion = Math.PI / 180;

            if (drawTargetDot) {
                let dotRad = dotDeg * radConversion;
                let dx = cx + Math.cos(dotRad) * radius;
                let dy = cy + Math.sin(dotRad) * radius;
                ctx.fillStyle = '#ff1744';
                ctx.beginPath();
                ctx.arc(dx, dy, 12, 0, Math.PI * 2);
                ctx.fill();
            }

            let lineRad = lineDeg * radConversion;
            let lx = cx + Math.cos(lineRad) * radius;
            let ly = cy + Math.sin(lineRad) * radius;
            ctx.fillStyle = '#ffffff';
            ctx.beginPath();
            ctx.arc(lx, ly, 12, 0, Math.PI * 2);
            ctx.fill();
        }

        window.addEventListener('keydown', function(e) {
            if (e.code === 'Space') {
                e.preventDefault();
                checkPlayerTap();
            }
        });

        window.addEventListener('mousedown', function(e) {
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'BUTTON') return;
            e.preventDefault();
            checkPlayerTap();
        });

        init();
    </script>
</body>
</html>