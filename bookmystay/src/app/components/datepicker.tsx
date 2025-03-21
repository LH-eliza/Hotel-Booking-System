import React, { JSX, useState, useEffect } from "react";

interface DateRange {
  startDate: string;
  endDate: string;
}

interface MonthData {
  name: string;
  days: number;
  startDay: number;
}

interface SimpleDatePickerProps {
  onDateChange: (dateRange: DateRange) => void;
  initialDateRange?: DateRange;
}

const SimpleDatePicker: React.FC<SimpleDatePickerProps> = ({
  onDateChange,
  initialDateRange,
}) => {
  const [showCalendar, setShowCalendar] = useState<boolean>(false);
  const [dateRange, setDateRange] = useState<DateRange>({
    startDate: "",
    endDate: "",
  });

  // Initialize date range from props if provided
  useEffect(() => {
    if (initialDateRange?.startDate && initialDateRange?.endDate) {
      setDateRange(initialDateRange);
    }
  }, [initialDateRange]);

  const today = new Date();
  const currentMonth = today.getMonth();
  const currentYear = today.getFullYear();

  const months: MonthData[] = [
    {
      name: new Date(currentYear, currentMonth).toLocaleString("default", {
        month: "long",
        year: "numeric",
      }),
      days: getDaysInMonth(currentYear, currentMonth),
      startDay: new Date(currentYear, currentMonth, 1).getDay(),
    },
    {
      name: new Date(currentYear, currentMonth + 1).toLocaleString("default", {
        month: "long",
        year: "numeric",
      }),
      days: getDaysInMonth(currentYear, currentMonth + 1),
      startDay: new Date(currentYear, currentMonth + 1, 1).getDay(),
    },
  ];

  function getDaysInMonth(year: number, month: number): number {
    return new Date(year, month + 1, 0).getDate();
  }

  const toggleCalendar = (): void => {
    setShowCalendar(!showCalendar);
  };

  const getDisplayText = (): string => {
    if (!dateRange.startDate && !dateRange.endDate) {
      return "Check-in | Check-out";
    }

    return `${dateRange.startDate || "..."} → ${dateRange.endDate || "..."}`;
  };

  const handleDateClick = (day: number, monthIndex: number, yearIndex: number): void => {
    const selectedMonth = new Date(
      currentYear,
      currentMonth + monthIndex
    ).toLocaleString("default", { month: "short" });
    const formattedDate = `${selectedMonth} ${day} ${yearIndex}`;

    if (!dateRange.startDate || (dateRange.startDate && dateRange.endDate)) {
      setDateRange({
        startDate: formattedDate,
        endDate: "",
      });
    } else {
      const startDateObj = new Date(`${dateRange.startDate}, ${currentYear}`);
      const newDateObj = new Date(`${formattedDate}, ${currentYear}`);

      if (newDateObj > startDateObj) {
        const updatedRange = {
          startDate: dateRange.startDate,
          endDate: formattedDate,
        };
        setDateRange(updatedRange);
        onDateChange(updatedRange);
        setShowCalendar(false);
      } else {
        setDateRange({
          startDate: formattedDate,
          endDate: "",
        });
      }
    }
  };

  const renderMonth = (month: MonthData, monthIndex: number): JSX.Element => {
    const weekdays = ["S", "M", "T", "W", "T", "F", "S"];

    const emptyCells = Array(month.startDay)
      .fill(null)
      .map((_, i) => <div key={`empty-${i}`} className="w-8 h-8"></div>);

    const dayCells = Array(month.days)
      .fill(null)
      .map((_, i) => {
        const day = i + 1;
        const dateString = new Date(
          currentYear,
          currentMonth + monthIndex,
          day
        ).toLocaleString("default", { month: "short" });
        const formattedDate = `${dateString} ${day}`;

        const isSelected =
          dateRange.startDate === formattedDate ||
          dateRange.endDate === formattedDate;
        const isToday =
          day === today.getDate() &&
          monthIndex === 0 &&
          currentMonth === today.getMonth();

        let cellClasses =
          "w-8 h-8 rounded-full flex items-center justify-center cursor-pointer ";
        if (isSelected) {
          cellClasses += "bg-blue-500 text-white ";
        } else if (isToday) {
          cellClasses += "border border-blue-500 ";
        } else {
          cellClasses += "hover:bg-gray-100 ";
        }

        return (
          <div
            key={`day-${day}`}
            onClick={() => handleDateClick(day, monthIndex, currentYear)}
          >
            <div className={cellClasses}>{day}</div>
          </div>
        );
      });

    return (
      <div>
        <div className="font-medium mb-2">{month.name}</div>
        <div className="grid grid-cols-7 gap-1 mb-1">
          {weekdays.map((day, i) => (
            <div key={i} className="text-center text-xs text-gray-500">
              {day}
            </div>
          ))}
        </div>
        <div className="grid grid-cols-7 gap-1">
          {emptyCells}
          {dayCells}
        </div>
      </div>
    );
  };

  return (
    <div className="relative">
      <input
        type="text"
        readOnly
        className="w-full text-sm focus:outline-none cursor-pointer"
        placeholder="Check-in | Check-out"
        value={getDisplayText()}
        onClick={toggleCalendar}
      />

      {showCalendar && (
        <div className="absolute z-10 mt-2 bg-white rounded-lg shadow-lg border border-gray-200 p-4 w-[500px]">
          <div className="flex justify-between mb-4">
            <div className="text-lg font-semibold">Select dates</div>
            <button
              className="text-blue-500 text-sm"
              onClick={() => setDateRange({ startDate: "", endDate: "" })}
            >
              Reset
            </button>
          </div>

          <div className="flex space-x-6">
            {months.map((month, i) => (
              <div key={i} className="flex-1">
                {renderMonth(month, i)}
              </div>
            ))}
          </div>

          <div className="mt-4 flex justify-end">
            <button
              className="px-4 py-2 bg-blue-500 text-white rounded-full font-medium text-sm"
              onClick={() => setShowCalendar(false)}
            >
              Done
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default SimpleDatePicker;
