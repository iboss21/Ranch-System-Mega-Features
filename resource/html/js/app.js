/**
 * Ranch System - Omni Frontier
 * Supreme UI JavaScript Controller
 * RedM NUI Compatible
 */

// Global state management
let ranchData = {
    ranchId: null,
    ranchName: "Circle T Ranch",
    balance: 0,
    level: 1,
    xp: 0,
    livestock: [],
    workforce: [],
    tasks: [],
    economy: {},
    environment: {},
    progression: {}
};

// UI State
let currentTab = 'dashboard';

/**
 * Initialize UI when ready
 */
$(document).ready(function() {
    console.log("Ranch UI System Initialized");
    
    // Listen for NUI messages from RedM
    window.addEventListener('message', function(event) {
        handleNUIMessage(event.data);
    });
    
    // ESC key to close UI
    $(document).keyup(function(e) {
        if (e.key === "Escape") {
            closeUI();
        }
    });
});

/**
 * Handle NUI messages from Lua
 */
function handleNUIMessage(data) {
    console.log("NUI Message:", data);
    
    switch(data.action) {
        case 'open':
            openUI(data.ranchData);
            break;
        case 'close':
            closeUI();
            break;
        case 'updateRanchData':
            updateRanchData(data.ranchData);
            break;
        case 'updateLivestock':
            updateLivestock(data.livestock);
            break;
        case 'updateWorkforce':
            updateWorkforce(data.workforce);
            break;
        case 'updateEconomy':
            updateEconomy(data.economy);
            break;
        case 'updateEnvironment':
            updateEnvironment(data.environment);
            break;
        case 'updateProgression':
            updateProgression(data.progression);
            break;
        case 'addActivity':
            addActivity(data.activity);
            break;
        case 'showNotification':
            showNotification(data.message, data.type);
            break;
    }
}

/**
 * Open the UI
 */
function openUI(data) {
    $('#ranchUI').fadeIn(300);
    if (data) {
        updateRanchData(data);
    }
    // Notify Lua that UI is open
    $.post('https://ranch-system-omni/uiOpened', JSON.stringify({}));
}

/**
 * Close the UI
 */
function closeUI() {
    $('#ranchUI').fadeOut(300);
    // Notify Lua that UI is closed
    $.post('https://ranch-system-omni/uiClosed', JSON.stringify({}));
}

/**
 * Show specific tab
 */
function showTab(tabName) {
    // Update button states
    $('.tab-btn').removeClass('active');
    $(`.tab-btn:contains('${capitalizeFirst(tabName)}')`).parent().find(`button[onclick="showTab('${tabName}')"]`).addClass('active');
    
    // Update content visibility
    $('.tab-content').removeClass('active');
    $(`#${tabName}`).addClass('active');
    
    currentTab = tabName;
    
    // Load tab-specific data
    loadTabData(tabName);
}

/**
 * Load data for specific tab
 */
function loadTabData(tabName) {
    switch(tabName) {
        case 'livestock':
            renderLivestock();
            break;
        case 'workforce':
            renderWorkforce();
            break;
        case 'economy':
            renderEconomy();
            break;
        case 'environment':
            renderEnvironment();
            break;
        case 'admin':
            loadAdminLogs();
            break;
    }
}

/**
 * Update ranch data
 */
function updateRanchData(data) {
    if (!data) return;
    
    // Merge data
    Object.assign(ranchData, data);
    
    // Update header
    $('#ranchName').text(data.ranchName || ranchData.ranchName);
    
    // Update dashboard stats
    $('#totalAnimals').text(data.totalAnimals || (data.livestock ? data.livestock.length : 0));
    $('#totalWorkers').text(data.totalWorkers || (data.workforce ? data.workforce.length : 0));
    $('#ranchBalance').text('$' + formatNumber(data.balance || 0));
    $('#ranchLevel').text(data.level || 1);
    
    // Update health bars
    if (data.cleanliness !== undefined) {
        updateProgressBar('cleanliness', data.cleanliness);
    }
    if (data.morale !== undefined) {
        updateProgressBar('morale', data.morale);
    }
    if (data.integrity !== undefined) {
        updateProgressBar('integrity', data.integrity);
    }
}

/**
 * Update progress bar
 */
function updateProgressBar(id, value) {
    const percentage = Math.round(value * 100);
    $(`#${id}Bar`).css('width', percentage + '%');
    $(`#${id}Value`).text(percentage + '%');
}

/**
 * Update livestock data
 */
function updateLivestock(livestock) {
    if (!livestock) return;
    ranchData.livestock = livestock;
    if (currentTab === 'livestock') {
        renderLivestock();
    }
}

/**
 * Render livestock cards
 */
function renderLivestock() {
    const grid = $('#livestockGrid');
    grid.empty();
    
    if (!ranchData.livestock || ranchData.livestock.length === 0) {
        grid.html(`
            <div class="livestock-card">
                <div class="animal-icon">
                    <i class="fas fa-horse"></i>
                </div>
                <h4>No Animals</h4>
                <p>Add animals to your ranch to get started.</p>
            </div>
        `);
        return;
    }
    
    ranchData.livestock.forEach(animal => {
        const icon = getAnimalIcon(animal.species);
        const card = $(`
            <div class="livestock-card" data-animal-id="${animal.id}">
                <div class="animal-icon">
                    <i class="${icon}"></i>
                </div>
                <h4>${animal.name || 'Unnamed'}</h4>
                <p>Species: ${capitalizeFirst(animal.species)}</p>
                <p>Health: ${Math.round((animal.health || 1) * 100)}%</p>
                <p>Trust: ${Math.round((animal.trust || 0.5) * 100)}%</p>
            </div>
        `);
        
        card.click(function() {
            viewAnimalDetails(animal.id);
        });
        
        grid.append(card);
    });
}

/**
 * Get icon for animal species
 */
function getAnimalIcon(species) {
    const icons = {
        'horse': 'fas fa-horse',
        'cattle': 'fas fa-cow',
        'sheep': 'fas fa-sheep',
        'pig': 'fas fa-piggy-bank',
        'chicken': 'fas fa-egg',
        'goat': 'fas fa-mountain',
        'dog': 'fas fa-dog',
        'cat': 'fas fa-cat'
    };
    return icons[species] || 'fas fa-paw';
}

/**
 * Update workforce data
 */
function updateWorkforce(workforce) {
    if (!workforce) return;
    ranchData.workforce = workforce;
    if (currentTab === 'workforce') {
        renderWorkforce();
    }
}

/**
 * Render workforce
 */
function renderWorkforce() {
    const list = $('#workforceList');
    list.empty();
    
    if (!ranchData.workforce || ranchData.workforce.length === 0) {
        list.html(`
            <div class="worker-card">
                <div class="worker-info">
                    <i class="fas fa-user"></i>
                    <span>No workers assigned. Hire workers to help manage your ranch.</span>
                </div>
            </div>
        `);
        return;
    }
    
    ranchData.workforce.forEach(worker => {
        const card = $(`
            <div class="worker-card">
                <div class="worker-info">
                    <i class="fas fa-user"></i>
                    <div>
                        <h4>${worker.name || 'Unnamed Worker'}</h4>
                        <p>Role: ${worker.role || 'Hand'}</p>
                        <p>Morale: ${Math.round((worker.morale || 0.8) * 100)}%</p>
                        <p>Fatigue: ${Math.round((worker.fatigue || 0.2) * 100)}%</p>
                    </div>
                </div>
            </div>
        `);
        list.append(card);
    });
    
    // Render tasks
    renderTasks();
}

/**
 * Render tasks
 */
function renderTasks() {
    const taskList = $('#taskList');
    taskList.empty();
    
    if (!ranchData.tasks || ranchData.tasks.length === 0) {
        taskList.html('<p style="color: var(--text-secondary); text-align: center;">No active tasks</p>');
        return;
    }
    
    ranchData.tasks.forEach(task => {
        const taskItem = $(`
            <div class="activity-item">
                <span class="activity-time">${task.type || 'Task'}</span>
                <span class="activity-text">${task.description || 'No description'}</span>
            </div>
        `);
        taskList.append(taskItem);
    });
}

/**
 * Update economy data
 */
function updateEconomy(economy) {
    if (!economy) return;
    ranchData.economy = economy;
    if (currentTab === 'economy') {
        renderEconomy();
    }
}

/**
 * Render economy tab
 */
function renderEconomy() {
    // Update ledger
    const totalIncome = ranchData.economy.totalIncome || 0;
    const totalExpenses = ranchData.economy.totalExpenses || 0;
    const netBalance = totalIncome - totalExpenses;
    
    $('#totalIncome').text('$' + formatNumber(totalIncome));
    $('#totalExpenses').text('$' + formatNumber(totalExpenses));
    $('#netBalance').text('$' + formatNumber(netBalance));
    
    // Render market prices
    const marketList = $('#marketPrices');
    marketList.empty();
    
    if (ranchData.economy.prices) {
        Object.keys(ranchData.economy.prices).forEach(product => {
            const price = ranchData.economy.prices[product];
            const item = $(`
                <div class="activity-item">
                    <span class="activity-time">${capitalizeFirst(product)}</span>
                    <span class="activity-text">$${price.toFixed(2)}</span>
                </div>
            `);
            marketList.append(item);
        });
    } else {
        marketList.html('<p style="color: var(--text-secondary); text-align: center;">No market data available</p>');
    }
    
    // Render contracts
    const contractsList = $('#contractsList');
    contractsList.empty();
    
    if (ranchData.economy.contracts && ranchData.economy.contracts.length > 0) {
        ranchData.economy.contracts.forEach(contract => {
            const contractItem = $(`
                <div class="activity-item">
                    <span class="activity-time">${contract.town || 'Unknown'}</span>
                    <span class="activity-text">${contract.description || 'No description'} - $${contract.reward || 0}</span>
                </div>
            `);
            contractsList.append(contractItem);
        });
    } else {
        contractsList.html('<p style="color: var(--text-secondary); text-align: center;">No active contracts</p>');
    }
}

/**
 * Update environment data
 */
function updateEnvironment(environment) {
    if (!environment) return;
    ranchData.environment = environment;
    
    // Update header season/weather
    if (environment.season) {
        $('#currentSeason').html(`<i class="${getSeasonIcon(environment.season)}"></i> ${capitalizeFirst(environment.season)}`);
    }
    if (environment.weather) {
        $('#currentWeather').html(`<i class="${getWeatherIcon(environment.weather)}"></i> ${capitalizeFirst(environment.weather)}`);
    }
    
    if (currentTab === 'environment') {
        renderEnvironment();
    }
}

/**
 * Render environment tab
 */
function renderEnvironment() {
    const env = ranchData.environment;
    
    if (env.season) {
        $('#seasonName').text(capitalizeFirst(env.season));
        $('#seasonIcon').html(`<i class="${getSeasonIcon(env.season)}"></i>`);
        
        // Season description
        const descriptions = {
            'spring': 'Grass is growing, animals are active',
            'summer': 'Hot and dry, watch for droughts',
            'autumn': 'Harvest time, prepare for winter',
            'winter': 'Cold weather, increased feed demand'
        };
        $('#seasonDescription').text(descriptions[env.season] || 'Season in progress');
    }
    
    if (env.weather) {
        const weatherIcon = getWeatherIcon(env.weather);
        $('.weather-icon-large').removeClass().addClass('weather-icon-large ' + weatherIcon);
        $('.weather-type').text(capitalizeFirst(env.weather));
    }
    
    if (env.temperature !== undefined) {
        $('.temperature').text(env.temperature + '°F');
    }
    
    // Render hazards
    const hazardsList = $('#hazardsList');
    hazardsList.empty();
    
    if (env.hazards && env.hazards.length > 0) {
        env.hazards.forEach(hazard => {
            const hazardItem = $(`
                <div class="activity-item">
                    <span class="activity-time">${capitalizeFirst(hazard.type)}</span>
                    <span class="activity-text">${hazard.description || 'Active hazard'}</span>
                </div>
            `);
            hazardsList.append(hazardItem);
        });
    } else {
        hazardsList.html('<p class="no-hazards">No active hazards</p>');
    }
}

/**
 * Get season icon
 */
function getSeasonIcon(season) {
    const icons = {
        'spring': 'fas fa-leaf',
        'summer': 'fas fa-sun',
        'autumn': 'fas fa-tree',
        'winter': 'fas fa-snowflake'
    };
    return icons[season] || 'fas fa-calendar';
}

/**
 * Get weather icon
 */
function getWeatherIcon(weather) {
    const icons = {
        'clear': 'fas fa-sun',
        'rain': 'fas fa-cloud-rain',
        'storm': 'fas fa-cloud-bolt',
        'snow': 'fas fa-snowflake',
        'fog': 'fas fa-smog'
    };
    return icons[weather] || 'fas fa-cloud';
}

/**
 * Update progression data
 */
function updateProgression(progression) {
    if (!progression) return;
    ranchData.progression = progression;
}

/**
 * Add activity to feed
 */
function addActivity(activity) {
    const activityList = $('#activityList');
    const item = $(`
        <div class="activity-item">
            <span class="activity-time">${activity.time || 'Just now'}</span>
            <span class="activity-text">${activity.text || ''}</span>
        </div>
    `);
    activityList.prepend(item);
    
    // Keep only last 10 items
    activityList.children().slice(10).remove();
}

/**
 * Show notification
 */
function showNotification(message, type) {
    // Simple notification - can be enhanced
    console.log(`[${type}] ${message}`);
    addActivity({ time: 'Just now', text: message });
}

/**
 * Admin Actions
 */
function adminAction(action) {
    console.log("Admin action:", action);
    
    // Send to Lua backend
    $.post('https://ranch-system-omni/adminAction', JSON.stringify({
        action: action
    }));
}

/**
 * Show hire dialog
 */
function showHireDialog() {
    $.post('https://ranch-system-omni/showHireDialog', JSON.stringify({}));
}

/**
 * View animal details
 */
function viewAnimalDetails(animalId) {
    $.post('https://ranch-system-omni/viewAnimalDetails', JSON.stringify({
        animalId: animalId
    }));
}

/**
 * Load admin logs
 */
function loadAdminLogs() {
    const logList = $('#adminLogs');
    logList.html('<p style="color: var(--text-secondary); text-align: center;">Loading admin logs...</p>');
    
    $.post('https://ranch-system-omni/getAdminLogs', JSON.stringify({}), function(logs) {
        logList.empty();
        if (logs && logs.length > 0) {
            logs.forEach(log => {
                const logItem = $(`
                    <div class="activity-item">
                        <span class="activity-time">${log.time || ''}</span>
                        <span class="activity-text">${log.message || ''}</span>
                    </div>
                `);
                logList.append(logItem);
            });
        } else {
            logList.html('<p style="color: var(--text-secondary); text-align: center;">No admin logs available</p>');
        }
    });
}

/**
 * Utility: Format number with commas
 */
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

/**
 * Utility: Capitalize first letter
 */
function capitalizeFirst(str) {
    if (!str) return '';
    return str.charAt(0).toUpperCase() + str.slice(1);
}

// Export functions for global access
window.closeUI = closeUI;
window.showTab = showTab;
window.adminAction = adminAction;
window.showHireDialog = showHireDialog;
