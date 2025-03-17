import React, { useState } from "react";
import { Minus, Plus, ChevronDown } from "lucide-react";

interface Room {
  id: number;
  name: string;
  adults: number;
  children: number;
}

interface GuestData {
  rooms: Room[];
  displayText: string;
}

interface GuestSelectorProps {
  onSelect?: (data: GuestData) => void;
}

const GuestSelector: React.FC<GuestSelectorProps> = ({ onSelect }) => {
  const [isOpen, setIsOpen] = useState<boolean>(false);
  const [rooms, setRooms] = useState<Room[]>([
    {
      id: 1,
      name: "Room 1",
      adults: 2,
      children: 0,
    },
  ]);

  const updateRoomGuests = (
    roomId: number,
    type: keyof Room,
    value: string | number
  ): void => {
    setRooms((prev) =>
      prev.map((room) =>
        room.id === roomId ? { ...room, [type]: value } : room
      )
    );
  };

  const increaseGuests = (
    roomId: number,
    type: "adults" | "children"
  ): void => {
    const room = rooms.find((r) => r.id === roomId);
    if (room) {
      if (type === "adults" && room.adults < 10) {
        updateRoomGuests(roomId, type, room.adults + 1);
      } else if (type === "children" && room.children < 10) {
        updateRoomGuests(roomId, type, room.children + 1);
      }
    }
  };

  const decreaseGuests = (
    roomId: number,
    type: "adults" | "children"
  ): void => {
    const room = rooms.find((r) => r.id === roomId);
    if (room) {
      if (type === "adults" && room.adults > 1) {
        updateRoomGuests(roomId, type, room.adults - 1);
      } else if (type === "children" && room.children > 0) {
        updateRoomGuests(roomId, type, room.children - 1);
      }
    }
  };

  const addRoom = (): void => {
    const newRoomId = Math.max(...rooms.map((r) => r.id)) + 1;
    setRooms([
      ...rooms,
      {
        id: newRoomId,
        name: `Room ${newRoomId}`,
        adults: 1,
        children: 0,
      },
    ]);
  };

  const removeRoom = (roomId: number): void => {
    if (rooms.length > 1) {
      setRooms((prev) => prev.filter((room) => room.id !== roomId));
    }
  };

  const handleDone = (e: React.MouseEvent): void => {
    // Stop event propagation to prevent it from bubbling up
    e.stopPropagation();

    setIsOpen(false);

    // Calculate total number of guests
    const totalAdults = rooms.reduce((sum, room) => sum + room.adults, 0);
    const totalChildren = rooms.reduce((sum, room) => sum + room.children, 0);
    const totalGuests = totalAdults + totalChildren;

    // Format display text
    let displayText = `${totalGuests} Guest${totalGuests !== 1 ? "s" : ""}`;
    if (rooms.length > 1) {
      displayText += ` · ${rooms.length} Rooms`;
    }

    if (onSelect) {
      onSelect({ rooms, displayText });
    }
  };

  const toggleDropdown = (e: React.MouseEvent): void => {
    // Stop event propagation to prevent it from bubbling up
    e.stopPropagation();
    setIsOpen(!isOpen);
  };

  const totalGuests = rooms.reduce(
    (sum, room) => sum + room.adults + room.children,
    0
  );
  const displayText = totalGuests === 1 ? "1 Guest" : `${totalGuests} Guests`;

  return (
    <div className="relative w-full">
      <button
        type="button"
        className="w-full text-left text-sm flex items-center justify-between focus:outline-none"
        onClick={toggleDropdown}
      >
        <span>{displayText}</span>
        <ChevronDown size={16} className="ml-2" />
      </button>

      {isOpen && (
        <div
          className="absolute top-full left-0 right-0 mt-2 bg-white shadow-lg rounded-lg p-4 z-20 w-72"
          onClick={(e) => e.stopPropagation()} // Prevent clicks inside from closing
        >
          {rooms.map((room) => (
            <div key={room.id} className="mb-4">
              <div className="flex justify-between items-center mb-3">
                <input
                  type="text"
                  value={room.name}
                  onChange={(e) =>
                    updateRoomGuests(room.id, "name", e.target.value)
                  }
                  className="border border-gray-300 rounded px-2 py-1 w-full"
                />
                {rooms.length > 1 && (
                  <button
                    type="button"
                    className="ml-2 text-gray-500 hover:text-gray-700"
                    onClick={() => removeRoom(room.id)}
                  >
                    ✕
                  </button>
                )}
              </div>

              <div className="flex justify-between items-center mb-2">
                <div>
                  <div>Adults</div>
                </div>
                <div className="flex items-center">
                  <button
                    type="button"
                    className="w-8 h-8 rounded-full border border-gray-300 flex items-center justify-center"
                    onClick={() => decreaseGuests(room.id, "adults")}
                    disabled={room.adults <= 1}
                  >
                    <Minus
                      size={16}
                      className={
                        room.adults <= 1 ? "text-gray-300" : "text-gray-700"
                      }
                    />
                  </button>
                  <span className="mx-4">{room.adults}</span>
                  <button
                    type="button"
                    className="w-8 h-8 rounded-full border border-gray-300 flex items-center justify-center"
                    onClick={() => increaseGuests(room.id, "adults")}
                    disabled={room.adults >= 10}
                  >
                    <Plus
                      size={16}
                      className={
                        room.adults >= 10 ? "text-gray-300" : "text-gray-700"
                      }
                    />
                  </button>
                </div>
              </div>

              <div className="flex justify-between items-center">
                <div>
                  <div>Children</div>
                  <div className="text-xs text-gray-500">Ages 0 to 17</div>
                </div>
                <div className="flex items-center">
                  <button
                    type="button"
                    className="w-8 h-8 rounded-full border border-gray-300 flex items-center justify-center"
                    onClick={() => decreaseGuests(room.id, "children")}
                    disabled={room.children <= 0}
                  >
                    <Minus
                      size={16}
                      className={
                        room.children <= 0 ? "text-gray-300" : "text-gray-700"
                      }
                    />
                  </button>
                  <span className="mx-4">{room.children}</span>
                  <button
                    type="button"
                    className="w-8 h-8 rounded-full border border-gray-300 flex items-center justify-center"
                    onClick={() => increaseGuests(room.id, "children")}
                    disabled={room.children >= 10}
                  >
                    <Plus
                      size={16}
                      className={
                        room.children >= 10 ? "text-gray-300" : "text-gray-700"
                      }
                    />
                  </button>
                </div>
              </div>
            </div>
          ))}

          <button
            type="button"
            className="text-blue-500 hover:text-blue-600 transition-colors font-medium mb-4"
            onClick={addRoom}
          >
            Add another room
          </button>

          <div className="flex justify-end">
            <button
              type="button"
              className="bg-blue-500 hover:bg-blue-600 text-white font-medium py-2 px-6 rounded-full transition-colors"
              onClick={handleDone}
            >
              Done
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default GuestSelector;
