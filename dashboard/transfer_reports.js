// Search
document.getElementById('searchInput').addEventListener('keyup', function() {
    const filter = this.value.toLowerCase();
    const rows = document.querySelectorAll('#reportsTable tr');

    rows.forEach(row => {
        const studentName = row.cells[1]?.textContent.toLowerCase() || '';
        const studentID = row.cells[2]?.textContent.toLowerCase() || '';

        row.style.display = (studentName.startsWith(filter) || studentID.startsWith(filter)) ? '' : 'none';
    });

    resetSelection();
});

// Select All (same dept only)
function toggleSelectAll() {
    const selectAll = document.getElementById('selectAll');
    const rows = document.querySelectorAll('#reportsTable tr:not([style*="display: none"])');
    const checkboxes = document.querySelectorAll('#reportsTable tr:not([style*="display: none"]) .row-checkbox');

    if (selectAll.checked && rows.length > 0) {
        const targetDept = rows[0].getAttribute('data-dept');
        let hasDifferentDept = false;

        rows.forEach(row => {
            if (row.getAttribute('data-dept') !== targetDept) hasDifferentDept = true;
        });

        if (hasDifferentDept) {
            alert('تنبيه: القائمة تحتوي على تخصصات مختلفة. يرجى الفلترة أولاً.');
            selectAll.checked = false;
            return;
        }

        checkboxes.forEach(cb => cb.checked = true);
    } else {
        checkboxes.forEach(cb => cb.checked = false);
    }

    updateCount();
}

function updateCount() {
    const selectedCheckboxes = document.querySelectorAll('.row-checkbox:checked');
    const selectedCountDisplay = document.getElementById('selectedCount');
    const currentDeptDisplay = document.getElementById('currentDept');

    if (selectedCheckboxes.length > 0) {
        const firstDept = selectedCheckboxes[0].closest('tr').getAttribute('data-dept');

        for (let i = 1; i < selectedCheckboxes.length; i++) {
            const currentDept = selectedCheckboxes[i].closest('tr').getAttribute('data-dept');
            if (currentDept !== firstDept) {
                alert('لا يمكن خلط التخصصات! يرجى اختيار طلاب من نفس القسم.');
                if (window.event) window.event.target.checked = false;
                return;
            }
        }
        currentDeptDisplay.innerText = firstDept;
    } else {
        currentDeptDisplay.innerText = 'الكل';
    }

    selectedCountDisplay.innerText = selectedCheckboxes.length;
}

function filterBy(dept) {
    const rows = document.querySelectorAll('#reportsTable tr');
    const deptDisplay = document.getElementById('currentDept');

    deptDisplay.innerText = dept === 'all' ? 'الكل' : dept;

    rows.forEach(row => {
        row.style.display = (dept === 'all' || row.getAttribute('data-dept') === dept) ? '' : 'none';
    });

    resetSelection();
}

function resetSelection() {
    document.getElementById('selectAll').checked = false;
    document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = false);
    updateCount();
}

async function bulkTransfer() {
    const selected = document.querySelectorAll('.row-checkbox:checked');
    const examinerSelect = document.getElementById('examinerList');
    const examinerText = examinerSelect.value;

    if (selected.length === 0) return alert('يرجى تحديد الطلاب أولاً.');
    if (examinerSelect.selectedIndex === 0) return alert('يرجى اختيار الممتحن المختص.');

    const studentDept = selected[0].closest('tr').getAttribute('data-dept');
    if (!examinerText.includes(studentDept)) {
        alert(`خطأ في المطابقة: تخصص الطلاب هو (${studentDept})، يرجى اختيار ممتحن من نفس القسم.`);
        return;
    }

    // Extract student IDs from selected rows
    const studentIds = [];
    selected.forEach(cb => {
        const row = cb.closest('tr');
        const studentId = row.getAttribute('data-student-id');
        if (studentId) studentIds.push(Number(studentId));
    });

    if (studentIds.length === 0) {
        // Fallback: use the row data if no data-student-id
        if (confirm(`تأكيد: تحويل ${selected.length} طلاب إلى ${examinerText}؟`)) {
            selected.forEach(cb => {
                const row = cb.closest('tr');
                row.style.transform = 'translateX(-50px)';
                row.style.opacity = '0';
                setTimeout(() => row.remove(), 500);
            });
            setTimeout(() => { alert('تم التحويل بنجاح!'); resetSelection(); }, 600);
        }
        return;
    }

    // Extract examiner ID from select option
    const examinerOption = examinerSelect.options[examinerSelect.selectedIndex];
    const examinerId = examinerOption.getAttribute('data-examiner-id');

    if (!confirm(`تأكيد: تحويل ${selected.length} طلاب إلى ${examinerText}؟`)) return;

    try {
        const result = await apiPost('/evaluation-list/send-to-examiner', {
            student_ids: studentIds,
            examiner_id: Number(examinerId),
        });

        if (result) {
            selected.forEach(cb => {
                const row = cb.closest('tr');
                row.style.transform = 'translateX(-50px)';
                row.style.opacity = '0';
                setTimeout(() => row.remove(), 500);
            });
            setTimeout(() => { alert(result.message || 'تم التحويل بنجاح!'); resetSelection(); }, 600);
        }
    } catch (e) {
        alert('حدث خطأ في التحويل');
    }
}
