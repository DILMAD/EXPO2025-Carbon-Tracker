// ===== Global Variables =====
let htmlComponent = null;
let currentPhase = 1;
let currentFootprint = null;
let availableActions = [];
let selectedActionIDs = [];
let impactData = null;

// ===== Required Setup Function =====
function setup(component) {
    htmlComponent = component;
    window.htmlComponent = component;
    
    console.log("Carbon Action Tracker initialized");
    
    // Set up event listeners for MATLAB responses
    htmlComponent.addEventListener("FootprintCalculated", handleFootprintCalculated);
    htmlComponent.addEventListener("ActionsLoaded", handleActionsLoaded);
    htmlComponent.addEventListener("ImpactCalculated", handleImpactCalculated);
    htmlComponent.addEventListener("SummaryGenerated", handleSummaryGenerated);
    htmlComponent.addEventListener("AppReset", handleAppReset);
    htmlComponent.addEventListener("Error", handleError);
    
    // Load theme preference
    loadTheme();
    
    // Initialize validation
    initializeValidation();
}

// ===== Theme Management =====
function loadTheme() {
    const savedTheme = localStorage.getItem('carbonTrackerTheme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
    updateThemeButton(savedTheme);
}

function toggleTheme() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('carbonTrackerTheme', newTheme);
    updateThemeButton(newTheme);
}

function updateThemeButton(theme) {
    const icon = document.getElementById('themeIcon');
    const label = document.getElementById('themeLabel');
    
    if (theme === 'dark') {
        icon.textContent = '🌙';
        label.textContent = 'Dark';
    } else {
        icon.textContent = '☀️';
        label.textContent = 'Light';
    }
}

// ===== Navigation =====
function switchTab(phase) {
    // Check if tab is unlocked
    const tab = document.getElementById(`tab${phase}`);
    if (tab.getAttribute('data-unlocked') === 'false') {
        return;
    }
    
    // Hide all phases
    document.querySelectorAll('.phase').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
    
    // Show selected phase
    document.getElementById(`phase${phase}`).classList.add('active');
    document.getElementById(`tab${phase}`).classList.add('active');
    
    currentPhase = phase;
}

function unlockTab(phase) {
    const tab = document.getElementById(`tab${phase}`);
    tab.setAttribute('data-unlocked', 'true');
}

// ===== Input Validation =====
function initializeValidation() {
    // Add default values to simplify testing
    setDefaultValues();
}

function setDefaultValues() {
    // Set reasonable defaults for quick testing
    document.getElementById('region').value = 'USA';
    document.getElementById('commuteMode').value = 'Car_Gasoline';
    document.getElementById('dailyCommuteKm').value = '20';
    document.getElementById('commuteDays').value = '250';
    document.getElementById('domesticFlights').value = '2';
    document.getElementById('avgDomesticFlightKm').value = '1500';
    document.getElementById('internationalFlights').value = '1';
    document.getElementById('avgInternationalFlightKm').value = '8000';
    document.getElementById('otherTravelKm').value = '50';
    document.getElementById('monthlyElectricityKWh').value = '900';
    document.getElementById('monthlyNaturalGasKWh').value = '300';
    document.getElementById('dietType').value = 'balanced';
    document.getElementById('streamingHoursPerDay').value = '2';
    document.getElementById('aiQueriesPerDay').value = '10';
    document.getElementById('cloudStorageGB').value = '100';
    document.getElementById('videoCallHoursPerWeek').value = '5';
    document.getElementById('emailsPerDay').value = '50';
    document.getElementById('shoppingFrequency').value = 'moderate';
    document.getElementById('clothingPurchases').value = '10';
    document.getElementById('electronicsPurchases').value = '1';
    document.getElementById('furniturePurchases').value = '0';
}

function validateInput(fieldId) {
    const field = document.getElementById(fieldId);
    const errorSpan = document.getElementById(`${fieldId}-error`);
    
    let isValid = true;
    let errorMessage = '';
    
    // Check if field has value
    if (!field.value || field.value === '') {
        isValid = false;
        errorMessage = 'This field is required';
    }
    
    // Validate numeric fields
    if (field.type === 'number' && field.value !== '') {
        const value = parseFloat(field.value);
        if (isNaN(value) || value < 0) {
            isValid = false;
            errorMessage = 'Must be a positive number';
        }
    }
    
    // Update UI
    if (isValid) {
        field.classList.remove('invalid');
        errorSpan.textContent = '';
    } else {
        field.classList.add('invalid');
        errorSpan.textContent = errorMessage;
    }
    
    return isValid;
}

function validateAllInputs() {
    const requiredFields = [
        'region', 'commuteMode', 'dailyCommuteKm', 'commuteDays',
        'domesticFlights', 'avgDomesticFlightKm', 'internationalFlights',
        'avgInternationalFlightKm', 'otherTravelKm', 'monthlyElectricityKWh',
        'monthlyNaturalGasKWh', 'dietType', 'streamingHoursPerDay',
        'aiQueriesPerDay', 'cloudStorageGB', 'videoCallHoursPerWeek',
        'emailsPerDay', 'shoppingFrequency', 'clothingPurchases',
        'electronicsPurchases', 'furniturePurchases'
    ];
    
    let allValid = true;
    requiredFields.forEach(fieldId => {
        if (!validateInput(fieldId)) {
            allValid = false;
        }
    });
    
    return allValid;
}

// ===== Phase 1: Calculate Footprint =====
function calculateFootprint() {
    console.log("Calculating footprint...");
    
    // Validate all inputs
    if (!validateAllInputs()) {
        showError('Please fill in all required fields correctly');
        return;
    }
    
    // Collect user data
    const userData = {
        region: document.getElementById('region').value,
        commuteMode: document.getElementById('commuteMode').value,
        dailyCommuteKm: parseFloat(document.getElementById('dailyCommuteKm').value),
        commuteDays: parseInt(document.getElementById('commuteDays').value),
        domesticFlights: parseInt(document.getElementById('domesticFlights').value),
        avgDomesticFlightKm: parseFloat(document.getElementById('avgDomesticFlightKm').value),
        internationalFlights: parseInt(document.getElementById('internationalFlights').value),
        avgInternationalFlightKm: parseFloat(document.getElementById('avgInternationalFlightKm').value),
        otherTravelKm: parseFloat(document.getElementById('otherTravelKm').value),
        monthlyElectricityKWh: parseFloat(document.getElementById('monthlyElectricityKWh').value),
        monthlyNaturalGasKWh: parseFloat(document.getElementById('monthlyNaturalGasKWh').value),
        dietType: document.getElementById('dietType').value,
        streamingHoursPerDay: parseFloat(document.getElementById('streamingHoursPerDay').value),
        aiQueriesPerDay: parseInt(document.getElementById('aiQueriesPerDay').value),
        cloudStorageGB: parseFloat(document.getElementById('cloudStorageGB').value),
        videoCallHoursPerWeek: parseFloat(document.getElementById('videoCallHoursPerWeek').value),
        emailsPerDay: parseInt(document.getElementById('emailsPerDay').value),
        shoppingFrequency: document.getElementById('shoppingFrequency').value,
        clothingPurchases: parseInt(document.getElementById('clothingPurchases').value),
        electronicsPurchases: parseInt(document.getElementById('electronicsPurchases').value),
        furniturePurchases: parseInt(document.getElementById('furniturePurchases').value)
    };
    
    // Show loading
    showLoading(true);
    
    // Send to MATLAB
    htmlComponent.sendEventToMATLAB("CalculateFootprint", userData);
}

function handleFootprintCalculated(event) {
    console.log("Footprint calculated:", event.Data);
    
    currentFootprint = event.Data;
    
    // Update Phase 2 UI
    updateFootprintDisplay(currentFootprint);
    
    // Unlock and switch to Phase 2
    unlockTab(2);
    switchTab(2);
    
    // Hide loading
    showLoading(false);
}

function updateFootprintDisplay(footprint) {
    // Update total
    document.getElementById('totalEmissions').textContent = footprint.totalTons.toFixed(1);
    
    // Create pie chart
    createPieChart(footprint);
    
    // Create comparison bars
    createComparisonBars(footprint);
    
    // Update Paris status
    updateParisStatus(footprint);
}

function createPieChart(footprint) {
    const pieChart = document.getElementById('pieChart');
    const pieLegend = document.getElementById('pieLegend');
    
    // Calculate angles for conic gradient
    const total = footprint.total;
    const categories = [
        { name: 'Transport', value: footprint.transport, color: '#2196F3', icon: '🚗' },
        { name: 'Home', value: footprint.home, color: '#FF9800', icon: '🏠' },
        { name: 'Food', value: footprint.food, color: '#4CAF50', icon: '🍽️' },
        { name: 'Digital', value: footprint.digital, color: '#9C27B0', icon: '💻' },
        { name: 'Consumption', value: footprint.consumption, color: '#795548', icon: '🛍️' }
    ];
    
    // Build conic gradient
    let angle = 0;
    let gradientStops = [];
    
    categories.forEach((cat, index) => {
        const percent = (cat.value / total) * 100;
        const nextAngle = angle + (percent * 3.6); // Convert % to degrees
        
        gradientStops.push(`${cat.color} ${angle}deg ${nextAngle}deg`);
        angle = nextAngle;
    });
    
    pieChart.style.background = `conic-gradient(${gradientStops.join(', ')})`;
    
    // Build legend
    pieLegend.innerHTML = '';
    categories.forEach(cat => {
        const percent = ((cat.value / total) * 100).toFixed(1);
        const tons = (cat.value / 1000).toFixed(2);
        
        const item = document.createElement('div');
        item.className = 'legend-item';
        item.innerHTML = `
            <div class="legend-color" style="background: ${cat.color};"></div>
            <span class="legend-label">${cat.icon} ${cat.name}</span>
            <span class="legend-value">${tons}t (${percent}%)</span>
        `;
        pieLegend.appendChild(item);
    });
}

function createComparisonBars(footprint) {
    const container = document.getElementById('comparisonBars');
    
    const comparisons = [
        { label: 'You', value: footprint.totalTons, class: 'user' },
        { label: `${footprint.regionalAvg ? 'Regional Avg' : 'Regional'}`, value: footprint.regionalAvg || 0, class: '' },
        { label: 'Global Avg', value: footprint.globalAvg, class: '' },
        { label: 'Paris 2030', value: footprint.parisTarget, class: 'target' }
    ];
    
    const maxValue = Math.max(...comparisons.map(c => c.value));
    
    container.innerHTML = '';
    comparisons.forEach(comp => {
        const widthPercent = (comp.value / maxValue) * 100;
        
        const item = document.createElement('div');
        item.className = 'comparison-bar-item';
        item.innerHTML = `
            <div class="comparison-bar-label">${comp.label}</div>
            <div class="comparison-bar-container">
                <div class="comparison-bar ${comp.class}" style="width: ${widthPercent}%">
                    ${comp.value.toFixed(1)}t
                </div>
            </div>
        `;
        container.appendChild(item);
    });
}

function updateParisStatus(footprint) {
    const statusDiv = document.getElementById('parisStatus');
    statusDiv.className = `paris-status ${footprint.parisStatus}`;
    
    let icon, message;
    if (footprint.parisStatus === 'aligned') {
        icon = '✅';
        message = `You're on track! Your footprint of ${footprint.totalTons.toFixed(1)} tons is below the 2030 Paris Agreement target of 2.0 tons.`;
    } else if (footprint.parisStatus === 'close') {
        icon = '⚠️';
        message = `You're close! Reduce by ${(footprint.totalTons - 2.0).toFixed(1)} tons to meet the 2030 Paris target.`;
    } else {
        icon = '❌';
        message = `You're ${(footprint.totalTons - 2.0).toFixed(1)} tons above the 2030 Paris target. Let's find ways to reduce!`;
    }
    
    statusDiv.innerHTML = `
        <div class="icon">${icon}</div>
        <div class="message">${message}</div>
    `;
}

// ===== Phase 3: Explore Actions =====
function exploreActions() {
    console.log("Loading actions...");
    
    showLoading(true);
    
    // Request actions from MATLAB
    const requestData = {
        region: currentFootprint.region || document.getElementById('region').value,
        currentFootprint: currentFootprint
    };
    
    htmlComponent.sendEventToMATLAB("GetAvailableActions", requestData);
}

function handleActionsLoaded(event) {
    console.log("Actions loaded:", event.Data);
    
    availableActions = event.Data;
    selectedActionIDs = [];
    
    // Update Phase 3 UI
    displayActions(availableActions);
    updateLiveFeedback();
    
    // Unlock and switch to Phase 3
    unlockTab(3);
    switchTab(3);
    
    showLoading(false);
}

function displayActions(actions) {
    const container = document.getElementById('actionsList');
    container.innerHTML = '';
    
    // Group actions by category
    const categories = {
        'Transport': { icon: '🚗', actions: [] },
        'Home': { icon: '🏠', actions: [] },
        'Food': { icon: '🍽️', actions: [] },
        'Digital': { icon: '💻', actions: [] },
        'Consumption': { icon: '🛍️', actions: [] }
    };
    
    actions.forEach(action => {
        if (categories[action.Category]) {
            categories[action.Category].actions.push(action);
        }
    });
    
    // Create sections for each category
    Object.keys(categories).forEach(catName => {
        const catData = categories[catName];
        if (catData.actions.length === 0) return;
        
        const section = document.createElement('div');
        section.className = 'action-category';
        section.innerHTML = `<h3>${catData.icon} ${catName} Actions</h3>`;
        
        const list = document.createElement('div');
        list.className = 'action-list';
        
        catData.actions.forEach(action => {
            const item = document.createElement('div');
            item.className = 'action-item';
            item.onclick = () => toggleAction(action.ActionID);
            
            item.innerHTML = `
                <input type="checkbox" class="action-checkbox" id="action-${action.ActionID}" 
                       onchange="toggleAction(${action.ActionID})">
                <div class="action-details">
                    <div class="action-name">${action.ActionName}</div>
                    <div class="action-meta">
                        <span class="action-impact">-${action.BaseImpact_kg} kg/yr</span>
                        <span class="action-cost">💰 ${action.costLabel}</span>
                        <span class="action-difficulty">📊 ${action.Difficulty}</span>
                        <span class="action-time">⏱️ ${action.TimeToImplement}</span>
                    </div>
                </div>
            `;
            
            list.appendChild(item);
        });
        
        section.appendChild(list);
        container.appendChild(section);
    });
}

function toggleAction(actionID) {
    const checkbox = document.getElementById(`action-${actionID}`);
    const item = checkbox.closest('.action-item');
    
    if (selectedActionIDs.includes(actionID)) {
        // Deselect
        selectedActionIDs = selectedActionIDs.filter(id => id !== actionID);
        item.classList.remove('selected');
    } else {
        // Select
        selectedActionIDs.push(actionID);
        item.classList.add('selected');
    }
    
    // Recalculate impact in real-time
    calculateImpactRealTime();
}

function calculateImpactRealTime() {
    if (selectedActionIDs.length === 0) {
        updateLiveFeedback();
        return;
    }
    
    // Send to MATLAB for calculation
    const requestData = {
        region: document.getElementById('region').value,
        currentFootprint: currentFootprint,
        selectedActionIDs: selectedActionIDs,
        allActions: availableActions
    };
    
    htmlComponent.sendEventToMATLAB("CalculateActionImpact", requestData);
}

function handleImpactCalculated(event) {
    console.log("Impact calculated:", event.Data);
    
    impactData = event.Data;
    updateLiveFeedback(impactData);
}

function updateLiveFeedback(impact) {
    const currentTotal = document.getElementById('currentTotal');
    const projectedTotal = document.getElementById('projectedTotal');
    const reductionAmount = document.getElementById('reductionAmount');
    const parisMini = document.getElementById('parisMini');
    
    currentTotal.textContent = `${currentFootprint.totalTons.toFixed(1)} tons`;
    
    if (impact && impact.totalReduction > 0) {
        projectedTotal.textContent = `${impact.newTotal.toFixed(1)} tons`;
        reductionAmount.textContent = `-${(impact.totalReduction / 1000).toFixed(1)} tons (${impact.reductionPercent.toFixed(0)}%)`;
        
        // Update Paris status
        let parisMessage;
        if (impact.parisStatus === 'aligned') {
            parisMessage = 'Paris Status: <strong style="color: #A5D6A7;">✓ On Track!</strong>';
        } else if (impact.parisStatus === 'close') {
            parisMessage = 'Paris Status: <strong style="color: #FFF59D;">⚠ Close</strong>';
        } else {
            parisMessage = 'Paris Status: <strong style="color: #FFCDD2;">Still Above Target</strong>';
        }
        parisMini.innerHTML = `<span class="paris-indicator">${parisMessage}</span>`;
    } else {
        projectedTotal.textContent = `${currentFootprint.totalTons.toFixed(1)} tons`;
        reductionAmount.textContent = `0.0 tons (0%)`;
        parisMini.innerHTML = '<span class="paris-indicator">Select actions to see impact</span>';
    }
}

// ===== Phase 4: View Summary =====
function viewSummary() {
    if (selectedActionIDs.length === 0) {
        showError('Please select at least one action before viewing summary');
        return;
    }
    
    console.log("Generating summary...");
    
    showLoading(true);
    
    // Get selected action details
    const selectedActions = availableActions.filter(action => 
        selectedActionIDs.includes(action.ActionID)
    );
    
    // Request summary from MATLAB
    const requestData = {
        currentFootprint: currentFootprint,
        impact: impactData,
        selectedActions: selectedActions,
        region: document.getElementById('region').value
    };
    
    htmlComponent.sendEventToMATLAB("GenerateSummary", requestData);
}

function handleSummaryGenerated(event) {
    console.log("Summary generated");
    
    const summaryText = event.Data;
    
    // Update Phase 4 UI
    displaySummary(summaryText);
    
    // Unlock and switch to Phase 4
    unlockTab(4);
    switchTab(4);
    
    showLoading(false);
}

function displaySummary(summaryText) {
    // Display before/after bars
    const beforeBar = document.getElementById('beforeBar');
    const afterBar = document.getElementById('afterBar');
    const beforeLabel = document.getElementById('beforeLabel');
    const afterLabel = document.getElementById('afterLabel');
    
    const maxValue = Math.max(currentFootprint.totalTons, impactData.newTotal);
    const beforeWidth = (currentFootprint.totalTons / maxValue) * 100;
    const afterWidth = (impactData.newTotal / maxValue) * 100;
    
    beforeBar.style.width = `${beforeWidth}%`;
    afterBar.style.width = `${afterWidth}%`;
    beforeLabel.textContent = `${currentFootprint.totalTons.toFixed(1)} tons`;
    afterLabel.textContent = `${impactData.newTotal.toFixed(1)} tons`;
    
    // Display waterfall chart
    createWaterfallChart();
    
    // Display text summary
    document.getElementById('summaryText').textContent = summaryText;
}

function createWaterfallChart() {
    const container = document.getElementById('waterfallChart');
    container.innerHTML = '';
    
    if (!impactData || !impactData.actionDetails) return;
    
    // Sort actions by impact (descending)
    const sortedActions = [...impactData.actionDetails].sort((a, b) => b.impact - a.impact);
    
    const maxImpact = sortedActions[0].impact;
    
    sortedActions.forEach(action => {
        const widthPercent = (action.impact / maxImpact) * 100;
        
        const item = document.createElement('div');
        item.className = 'waterfall-item';
        item.innerHTML = `
            <div class="waterfall-label">${action.name}</div>
            <div class="waterfall-bar-container">
                <div class="waterfall-bar" style="width: ${widthPercent}%"></div>
                <div class="waterfall-value">-${action.impact.toFixed(0)} kg</div>
            </div>
        `;
        container.appendChild(item);
    });
}

// ===== Reset Functionality =====
function resetApp() {
    if (!confirm('Are you sure you want to reset? All data will be cleared.')) {
        return;
    }
    
    console.log("Resetting app...");
    
    // Send reset event to MATLAB
    htmlComponent.sendEventToMATLAB("ResetApp", {});
}

function handleAppReset(event) {
    console.log("App reset");
    
    // Reset global variables
    currentPhase = 1;
    currentFootprint = null;
    availableActions = [];
    selectedActionIDs = [];
    impactData = null;
    
    // Lock all tabs except first
    for (let i = 2; i <= 4; i++) {
        document.getElementById(`tab${i}`).setAttribute('data-unlocked', 'false');
    }
    
    // Clear all checkboxes
    document.querySelectorAll('.action-checkbox').forEach(cb => cb.checked = false);
    document.querySelectorAll('.action-item').forEach(item => item.classList.remove('selected'));
    
    // Reset to defaults
    setDefaultValues();
    
    // Switch to Phase 1
    switchTab(1);
}

// ===== Utility Functions =====
function showLoading(show) {
    const loading = document.getElementById('loading');
    if (show) {
        loading.classList.add('active');
    } else {
        loading.classList.remove('active');
    }
}

function showError(message) {
    const errorDiv = document.getElementById('errorMessage');
    errorDiv.textContent = message;
    errorDiv.classList.add('active');
    
    setTimeout(() => {
        errorDiv.classList.remove('active');
    }, 5000);
}

function handleError(event) {
    console.error("Error from MATLAB:", event.Data);
    showError(event.Data.message || 'An error occurred. Please try again.');
    showLoading(false);
}

// ===== Initialize on Load =====
console.log("Carbon Action Tracker JavaScript loaded");